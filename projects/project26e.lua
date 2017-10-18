
-- 2x 7-seg modules, showing time & date
-- 16:02:59 06/12/2017 altered to 16-02-5906.12.2017 which fortuitously fits into 2 x 8 digits each (incl dec points!)


MAX_modules=2
dofile("lib-MAX7219.lua")
max7219.clear()

function refreshdisplay()
    max7219.write(Time():gsub(":", "-"):gsub("/","." ):gsub(" ",""))
end

tmr.alarm(4, 1000, 1, refreshdisplay)
