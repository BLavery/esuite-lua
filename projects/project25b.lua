print("TFT144 1 BMP icon")

DRAW_BMP=true
dofile("lib-TFT144.lua")

Disp.drawBMP("i.bmp", 107)  -- ie at location (107,0)

