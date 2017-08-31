print("Project 11: Deep Sleep Test")

-- NECESSARY: link these pins:  RST with D0 (ie gpio16)
--                & reset button may not function in this mode (depends on board circuits)
--                & don't forget to remove link for other projects, to avoid strange rebooting
-- Uses button on D3 as starter for test. This is the "flash" button on many nodemcu boards

dofile("lib-LOGGER.lua")  -- keeps a reset entry each startup
dofile("lib-DEEPSLEEP.lua")

function but3_cb()    -- button pressed
    DEEPSLEEP(6     ,  -- Time for each deep sleep.  MAX allowed = 71 minutes
             1,       -- def 0: 0=full delayed start each wake, 1 = full start w/o delay
                      -- 3=brief "peep wake" between sleeps, straight to project file 
             1)       -- How many successive sleeps before sequence finished? default 1
             
    -- and so a LONG sleep such as 24 hours could be made of say 24 x 60mins.
end

gpio.mode(3,gpio.INPUT)
gpio.trig(3, "down", but3_cb)  -- when button pressed

print("Press button D3 to start")

