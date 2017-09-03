print("Project 20: MQTT Thingspeak DHT22 Telnet Logger for ESP-01")
-- an untidy complicated little project suiting a ESP-01
-- "The mouse that roared"

-- logging weather station
-- DHT22 on pin D4/GPIO2
-- Captures ESP-01's D10 (TX pin) as controllable led, can set on/off via mqtt
-- ESP publishes Temp & Humidity every 15 mins to MQTT
-- ESP subscribes to topic LED10, allowing led control from mqtt
-- "Flash" button on D3/GPIO0 is monitored. On press, publish to mqtt.

-- This ESP-01 station is easy to construct:
-- Solder DHT11 directly to +3 GND and GPIO2 on the ESP01.
-- Get a "esp01 USB programmer adapter" now ubiquitous on eBay (abt $2)
-- Solder a miniature button to adapter underside D3/GPIO0 to GROUND. This becomes "flash" or user D3 button.
-- Use the USB adapter for flashing and for lua script uploads and testing. (Learn to use flash button manually!!)
-- Then plug it all into a wall power pack, using adapter as regulated power. Voila: a portable IoT unit.

-- And note that the regular serial port function is killed to allow led on esp01 to be a project gpio
-- So ESPlorer is offline. Use telnet on local network if you need.

dofile("lib-LOGGER.lua")

_,_,_,_,_,sz = node.info()  -- sixth return param is flash size
if sz > 1200 then print("This does not appear to be a ESP-01?") end

_MINS=60000
_SECS=1000

mqtt_topics = {Led10=1} 

function mqtt_ready()
     -- MQTT is up. Now we can schedule a regular publishing regime.
     ctr=0
     tmr.alarm(2, 15*_MINS, 1, function() 
         -- stagger 2 readings: our simple publish function needs time to process
         ctr = (ctr+1) 
         if (ctr % 2) == 0 then
            mqtt_publish("Temp", temp)
            postThingSpeak(1, temp, "Temp") 
         else
            mqtt_publish("Humidity", humidity)
            postThingSpeak(5, humidity, "Humidity") 
         end 
     end )
     --print("MQTT publishing scheduled")
     writeLog("MQTT connect")
end

function mqtt_recv(topic,data)
        print(topic .. ":" .. (data ~= nil and data or ""))
        if topic == "Led10" then 
            if data == "0" then gpio.write(10,1)
            else gpio.write(10,0) end
        end    
end

dofile("lib-MQTT.lua")
gpio.trig(3, "down", function() mqtt_publish("ButtonD3", string.sub(Time(),1,5)) end )
 
DHT = 4 -- gpio2
temp=0
humidity=0

function readWeather()
    stat, temp, humidity = dht.read(DHT)
end

function button_pressed(level, when)
    mqtt_publish("ButtonD3", string.sub(Time(),1,5))
end

-- a 60-second time displays on terminal or telnet
tmr.alarm(0, 1*_MINS, 1, function()
    readWeather()
    print(string.sub(Time(), 1,5), temp, humidity)
end)

-- an hourly timer for browser-based logger
tmr.alarm(3, 60*_MINS, 1, function()
    writeLog("T:"..temp.. " H:"..humidity)
end)

tport=23
dofile("lib-TELNET.lua")
dofile("lib-THINGSPEAK.lua")

-- init log entry
readWeather()
writeLog("T:"..temp.. " H:"..humidity)

-- ESP-01 has a useful LED on TX/gpio1 ("D10" in lua). Kill the local serial I/O.  Telnet still works.
-- Activate onboard LED on TX0 GPIO1  D10
-- 
print("Bye. Serial TX off (now GPIO D10).")
print("D10 controllable from MQTT as 'Led10'.")
print("Go use telnet. Or use uart.alt(0) from telnet to restore ESPlorer.")

tmr.alarm(1, 700, 0, function()  -- allow time for print() above to complete
    --uart.alt(1)
    gpio.mode(10,gpio.OUTPUT)   
    gpio.write(10,1) -- = led10 off
    -- which appears at TX pin of ESP01, 
    -- possible serial "stuff" to ESPlorer monitor if it is connected.  Ignorable?
    -- should be using telnet at local network anyway!
end )                                                     
