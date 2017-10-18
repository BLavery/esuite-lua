


dofile("lib-MAX7219.lua")


max7219.write("  test")


function refreshdisplay()
    max7219.write(string.sub(Time(),0,8):gsub(":", "-"))
end

tmr.alarm(4, 1000, 1, refreshdisplay)
