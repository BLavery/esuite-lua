print("Project 18: Simple Thingspeak")

-- recording analog A0 every 15 mins

if adc.force_init_mode(adc.INIT_ADC) then  
    node.restart()  
    return 
end  -- if adc mode was wrong mode from any earlier project, reboot correctly . Only ever needed once.

dofile("lib-THINGSPEAK.lua")

tmr.alarm(0, 900000, 0, function() 
    postThingSpeak(2, adc.read(0))       -- to thingspeak field 2 
end  )  

