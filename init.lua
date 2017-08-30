proj = "project01"

-- full init =
--    1 init  
--    2 WIFI
--    3 TIME
-- then your "project" is ready to start

-- following line makes some dofile("missingfile") into non-(panic/reboot):
local df=dofile dofile=function(f) if file.exists(f) then df(f) else print("File ", f, "not exist") return end end

-- refer lib-DEEPSLEEP.lua to understand these numbers
if rtcmem and rtcmem.read32(20) == 123654 then-- test if waking from deepsleep? (either timer or button)
    rtcmem.write32(20,654321) 
    -- if so, destroy that number against re-use, but leave its equivalent for our project to see
    local starttype = rtcmem.read32(22)
    if starttype == 1 then  
         node.task.post( function() dofile("init2-WIFI.lua") end ) -- faster than below
         return
    elseif starttype == 3 then 
         node.task.post( function() dofile(proj..".lua") end ) -- skip pause, wifi & sntp
         return
    end
    -- so, waking from deepsleep, but not doing any special fast start
end

-- below, doing regular delayed full start ...

wifi.setmode(wifi.STATION) 
print "Hold down button during blinking to abort..." 
gpio.mode(4,gpio.OUTPUT)   -- the led on ESP12 submodule
gpio.mode(3,gpio.INPUT)  -- make sure D3 button is working, & not left as an output since just before reset
pwm.setup(4,12,950)   -- flash
pwm.start(4)                                                          --   stage #1

tmr.alarm(0, 5000, 0, function()
        -- allow time for wifi to autostart, and time to salvage looping panics
        if rtctime.get() > 10 then print("Awake from Deep Sleep") end
        -- we arrive here after the X mseconds past reset
        -- see https://bigdanzblog.wordpress.com/2015/04/24/esp8266-nodemcu-interrupting-init-lua-during-boot/
        pwm.stop(4)
        pwm.close(4)          -- stop flash
        if gpio.read(3) == 0 then
            print "Button held: Aborted start."
            gpio.write(4,0)        -- turn on
            return  -- EXITS without anything else happening. flashing continues.
        end
        -- if we get here, we didn't press abort button
        gpio.write(4,1)        -- turn led off
        gpio.mode(4,0)         -- restore to regular input mode
        dofile("init2-WIFI.lua")
end)
-- early "stop timer 0" at ESPlorer can abort the init sequence


local rawcode,extcode = node.bootreason()
local rc={"Pwr on","Reset", "HW reset", "WDT reset"}
local ec={"Pwr on", "HW WDT", "Exception Crash", "SW WDT", "SW restart", "Deepsleep Wake", "EXT reset"}
--           0         1            2                3            4           5                 6
print(rc[rawcode], ec[extcode+1])
if extcode == 2 then print (node.bootreason()) end
-- BUT DON'T BELIEVE IT RELIGIOUSLY !!

