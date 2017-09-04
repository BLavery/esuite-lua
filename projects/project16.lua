print("Project: MQTT Demo  ")

dofile("lib-OLED.lua")  -- optional

-- TEST SETUP:
-- LDR from A0 to +3.3V
-- oled on default sda 2 scl 1
-- inbuilt flash button D3
-- inbuilt led D4 on the esp12 submodule

--MQTT broker - suggest CloudMQTT - set the config for login in file lib-MQTT.lua
--     5 data items being exchanged, 3 in (=subscribe), 2 out (=publish):
--ESP publishes (1) LDR (analog 0-1024) every 20 seconds to MQTT
--ESP subscribes to:
--    (2) Led1       If receives Led1=0 or 1, switches LED on GPIO D4 (on esp12)
--    (3) OledMsg    If receives OledMsg=xxxxx, displays xxxxx on journal line of Oled
--    (4) testButn   If receives testButn (any payload), reads FLASH button (D3) 
--                   and publishes (5) "Button=0" or =1 to MQTT  
--                   (ie phone effectively polls for D3 state)

-- Suggested MQTT app for your smartphone: MQTT Dashboard. Subscribe it to topics LDR and Button.
-- Publish 0 or 1 to Led1, a text message to OledMsg, and anything at all to testButn to poll D3 state.

if adc.force_init_mode(adc.INIT_ADC) then  
    node.restart()  
    return 
end  -- if adc mode was wrong, restart correctly 

gpio.mode(4,1) -- led output
gpio.mode(3,0) -- d3 input

-- MQTT topics to subscribe
mqtt_topics = {Led1=0, OledMsg=0, testButn=0} -- Add/remove topics to the array

-- a pretty simple project: just publish LIGHT level every 20 seconds. 
-- Note we must wait for MQTT to be all running before we can start this.
function mqtt_ready()
     tmr.alarm(2, 20000, 1, function() mqtt_publish("LDR", readLDR())  end )
end

-- actually, more interesting stuff gets triggered by the 3 incoming subscription messages:
function mqtt_recv(topic,data)
        print(topic .. ":" .. (data ~= nil and data or ""))
        
        if topic == "Led1" then gpio.write(4,data=="0" and 0 or 1) end
        if topic == "OledMsg" and oled ~= nil then oled("j",data) end
        if topic == "testButn" then mqtt_publish("Button", gpio.read(3)) end      
end

dofile("lib-MQTT.lua")

function readLDR()
    return adc.read(0)
    -- actually this simply reads raw analog (0-1024). 
    -- You may need to scale/calibrate this value to some light levels if you choose.
    -- eg return (1024-adc.read(0)) to invert the reading - higher = brighter
    -- or return (adc.read(0) > 450)  to return true/false meaning binary bright vs dark
 
end

-- a 10-second display on oled screen
tmr.alarm(0, 10000, 1, function()
    ldr = readLDR()
    tt = Time()
    if oled ~= nil then oled("jnl", string.sub(tt,1,8).. " LDR=" .. ldr ) end
    print ("LDR " .. ldr)
end)



