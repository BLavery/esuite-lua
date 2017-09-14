print("projZ06c.lua")

DRAW_BMP=true

dofile("lib-TFT144.lua")
Disp.drawBMP("bl.bmp") -- over a minute!!
Disp.drawBMP("gpio.bmp", 60,0)
