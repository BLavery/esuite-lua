-- This file creates a 7-seg font array to file "|char7seg" for using 7-segment MAX7219 module 

-- every ascii character into 7 segments is a tall ask, but creativity can be productive!
-- Edit the settings below as desired
 
print("Create 7Seg character file")

local digits={}
digits[" "] = 0x00
digits["-"] = 0x01
digits["_"] = 0x08 
digits["0"] = 0x7e
digits["1"] = 0x30
digits["2"] = 0x6d
digits["3"] = 0x79
digits["4"] = 0x33
digits["5"] = 0x5b
digits["6"] = 0x5f
digits["7"] = 0x70
digits["8"] = 0x7f
digits["9"] = 0x7b 
digits["a"] = 0x7d
digits["b"] = 0x1f
digits["c"] = 0x0d
digits["d"] = 0x3d
digits["e"] = 0x6f
digits["f"] = 0x47
digits["g"] = 0x7b
digits["h"] = 0x17
digits["i"] = 0x10
digits["j"] = 0x18
digits["k"] = 0x27
digits["l"] = 0x06
digits["m"] = 0x49
digits["n"] = 0x15
digits["o"] = 0x1d
digits["p"] = 0x67
digits["q"] = 0x73
digits["r"] = 0x05
digits["s"] = 0x5b
digits["t"] = 0x0f
digits["u"] = 0x1c
digits["v"] = 0x1c
--digits["w"] = 0x08 -- not supported
--digits["x"] = 0x08 -- not supported
digits["y"] = 0x3b
digits["z"] = 0x6d 
digits["A"] = 0x77
digits["B"] = 0x7f
digits["C"] = 0x4e
digits["D"] = 0x7e
digits["E"] = 0x4f
digits["F"] = 0x47
digits["G"] = 0x5e
digits["H"] = 0x37
digits["I"] = 0x30
digits["J"] = 0x38
digits["K"] = 0x27
digits["L"] = 0x0e
digits["M"] = 0x49
digits["N"] = 0x76
digits["O"] = 0x7e
digits["P"] = 0x67
digits["Q"] = 0x73
digits["R"] = 0x46
digits["S"] = 0x5b
digits["T"] = 0x0f
digits["U"] = 0x3e
digits["V"] = 0x3e
--digits["W"] = 0x08
--digits["X"] = 0x08 -- not supported
digits["Y"] = 0x3b
digits["Z"] = 0x6d
digits[","] = 0x80
digits["."] = 0x80
digits[":"] = 0x09
digits["="] = 0x09
digits["~"] = 0x40 
digits["#"] = 0x63 -- use for degrees symbol
digits["^"] = 0x23
digits['"'] = 0x22
digits["'"] = 0x02
digits["?"] = 0xe5  
digits["@"] = 0x7d
digits["!"] = 0xa0

file.open("|char7seg", "w")
local c, v
for c=1 , 129 do
    v = digits[string.char(c)]
    if v ~= nil then
        file.write(string.char(v))
    else
        file.write(string.char(0x08))  -- default display for no listing above (== underscore)
    end
end
file.close()


--[[  segment bits:

            6
         1     5
            0
         2     4
            3
            
                dp=7

--]]

