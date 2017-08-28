print("Project05b: SONAR - pump control")
  
-- hc-sr04 driver, used as water tank level sensor, pointing downwards to water surface
-- ref position = bottom of tank.  tank lip height 75 cm.   Sensor at height 80cm.
-- top-up pump goes ON when water falls to 20 cm from bottom.  Pump turns OFF at water height 60cm.
-- Manual/remote over-ride from phone (blynk). Water level display at phone.

dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )

vw_cb = function(cmd)  -- called when PUMP button pressed at phone
    pin=tonumber(cmd[2])
    if pin == 9 then -- vpin9??
        pumpon = (cmd[3] == '1') 
        print("From remote: Pump: ", pumpon)
        oled("j","(R) PUMP " .. (pumpon and "on  " or "off ") .. string.sub(Time(), 1,5) )
        gpio.write(RELAY, pumpon and 1 or 0)
    end
end

b=blynk.new (token, function(b) b:on("vw", vw_cb) end):connect()

dofile("lib-ULTRASONIC.lua")
dofile("lib-OLED.lua")

sonar = Sonar.new(7, 8):run()  -- trig, echo, led

RELAY = 4  -- this is led on esp12. In real life we would put a relay/contactor there for pump.
pumpon = false
gpio.mode(RELAY,gpio.OUTPUT)
gpio.write(RELAY,0)
water_HI = 60   -- (20 under sensor), pump should stop
water_LO = 20   -- (60cm below sensor) pump should start

function pumpcontrol()  -- called every 5 secs
    local sonrDist = sonar:read()
    local Level = 80 - sonrDist
    Level = (Level>0) and Level or 0  -- neg level is nonsense. faulty reading?
    if (not pumpon) and (Level < water_LO) then  
        pumpon = true
        oled("j","LO: PUMP on  ".. string.sub(Time(), 1,5) )
        print("pump on (water level lo)")
    elseif pumpon and (Level > water_HI) then
        pumpon = false
        oled("j","HI: PUMP off ".. string.sub(Time(), 1,5) )
        print("pump off (water level hi)")
    end
    gpio.write(RELAY, pumpon and 1 or 0)
    b:write('vw', 9, pumpon and 1 or 0) -- update on/off status of PUMP button on phone
    b:write("vw", 10, Level)  -- update water level gauge at phone
    print ("Sonar:", sonrDist, "Water:", Level, "pump="..(pumpon and "ON " or "OFF"))
end

tmr.alarm(0, 5000, 1, pumpcontrol)  -- perhaps 1 per minute - or use every 5 secs for testing

-- at ESP8266 use OLED on i2c (D2, D1), HC-sr04 at TRIG D6, ECHO D8 (via 6K resistor)
--         inbuilt led on D4 represents PUMP RELAY ON
-- at phone,  button vpin 9 labelled PUMP, scaled 0-1, switch  mode
--         and gauge vpin 10 labelled LEVEL, scaled 0-75, push mode (no timer poll)
