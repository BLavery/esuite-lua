dofile("lib-DEEPSLEEP.lua") -- if awaking from sleep & need more passes, we don't return from here: will sleep again.
-- NECESSARY: link these pins:  RST with D0 (ie gpio16)

-- and connect battery positive via resistor circuit to read on A0 (max 3.3V)
-- we monitor battery volts over time & record to thingspeak
-- over some days(?) battery should discharge, but deepsleep should make this much slower than all-the-time running.

print("Project 12: Deep Sleep Longevity Test, with Thingspeak")

if adc.force_init_mode(adc.INIT_ADC) then  
    node.restart()  
    return 
end  -- if adc mode was wrong mode from any earlier project, reboot correctly . Only ever needed once.

function dsleep()
    DEEPSLEEP(3600, 3, 2)  -- 120 mins as 2 passes x 60 minutes
end

dofile("lib-THINGSPEAK.lua")
dofile("lib-OLED.lua")

node.task.post(0, function() 
       postThingSpeak(2, adc.read(0), "PS volts", dsleep ) -- on its callback, we deepsleep again for 2 hrs
    end 
) 

tmr.alarm(0, 10000, 0, dsleep )  -- if thingspeak call above doesn't finish ok, we DS after 10 secs anyway

