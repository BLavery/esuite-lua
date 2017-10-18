

MAX_type=8
MAX_modules=1
dofile("lib-MAX7219.lua")
max7219.write("a")



ctr=1

tmr.alarm(4, 2000, 1, function() 
    ctr = 1-ctr 
    max7219.shutdown(ctr==0) 
end )
