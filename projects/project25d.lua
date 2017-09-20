print("TFT144 2 (big) images overlapping")

DRAW_BMP=true
dofile("lib-TFT144.lua")
draw2 = function()
    Disp.drawBMP("gpio.bmp")
end
Disp.drawBMP("bl.bmp",nil,nil,draw2) -- Draw other image after the first completes

