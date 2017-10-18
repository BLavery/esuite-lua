

MAX_type=8
MAX_modules=8
dofile("lib-MAX7219.lua")
max7219.write("TimeDemo")

function refreshdisplay()
    max7219.write(Time())
end

tmr.alarm(4, 2000, 1, refreshdisplay)
