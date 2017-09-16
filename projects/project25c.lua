print("TFT144 2 images not overlapping")

DRAW_BMP=true
dofile("lib-TFT144.lua")

tmr.alarm(0,2000,0,function()
    Disp.drawBMP("star.bmp", 100)
    Disp.drawBMP("i.bmp")
    -- line writes will time-interleave
end )
