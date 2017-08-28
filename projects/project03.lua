print("Project03: Blynk slider -> servo")
 
vw_cb = function(cmd)
    pin = tonumber(cmd[2])
    if pin == 3 then -- vpin3??
        posn = tonumber(cmd[3])
        print("New servo setting: ", posn)
        oled("b", {"Servo", posn} ) 
        sv:set(posn)
    end
end
 
setup_cb = function(b)
    b:on("vw", vw_cb)
end 
 
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
b=blynk.new (token, setup_cb):connect()

dofile("lib-SERVO.lua")
sv = Servo.new(5)   

dofile("lib-OLED.lua")

-- at ESP8266, we have a servomotor on pin D5, and oled on i2c D2,D1
-- at phone, use slider widget scaled 0-100, vpin 3
