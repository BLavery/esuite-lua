

dofile("lib-MAX7219.lua")


alfa= "0123456789 aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ !@#$%^&*()-_=+[{]}\|`~';:.>,</?"
pos=1

function refreshdisplay()
    max7219.write(alfa:sub(pos, pos+7))
    print(alfa:sub(pos, pos+7))
    pos = pos + 8
    if pos > #alfa then pos = pos - #alfa end
end

tmr.alarm(4, 6000, 1, refreshdisplay)
