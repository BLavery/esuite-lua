-- This project does nothing except detect if SNTP time syncing has failed during initialisation.
-- It schedules a repetitive (30 sec) retry of SNTP until success.

print("Project08 - Detect and retry SNTP fails")

dofile("lib-OLED.lua")

-- a function to recognise time/sntp failed, so schedule another attempt
if rtctime.get() < 1000000000 then 
    tmr.alarm(3, 30000, 1, function()  
        if rtctime.get() > 1000000000 then -- current/correct is > 1500000000, failed is near zero (=1970)
            tmr.stop(3)
        else 
            print("Retrying time")
            dofile("init3-TIME.lua") 
        end
    end 
    )
end

