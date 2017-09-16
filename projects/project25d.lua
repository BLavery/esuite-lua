print("TFT144 2 (big) images overlapping")

DRAW_BMP=true
dofile("lib-TFT144.lua")
Disp.drawBMP("bl.bmp",nil,nil,draw2) -- Draw other image after first completes

draw2 = function()
    Disp.drawBMP("gpio.bmp")
end
