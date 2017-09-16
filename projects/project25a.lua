print("TFT144 yell()")

dofile("lib-TFT144.lua")
tmr.alarm(0,2000,0,function()
    Disp.yell("        go", " BACK", "  again",nil,nil,nil,255,255)

end )
