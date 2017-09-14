print("projZ06b.lua")

DRAW_BMP=true

dofile("lib-TFT144.lua")

tmr.alarm(0,2000,0,function()
    Disp.yell("        go", " BACK", "  again",nil,nil,nil,255,255)
    Disp.drawBMP("star.bmp", 100,100)
    Disp.drawBMP("i.bmp", 0,105)
end )
