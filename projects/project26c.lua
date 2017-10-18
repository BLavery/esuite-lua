
dofile("lib-MAX7219.lua")
max7219.write("abcd 1234")




print("Align left / align right")
print("And note decimal point takes NO space")

ctr=1

tmr.alarm(4, 2000, 1, function() 
    ctr = 1-ctr 
    max7219.write("dec 3.89", ctr==0) -- right-align = true/false
end )


