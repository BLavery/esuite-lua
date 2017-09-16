-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/ucglib/GraphicsTest.lua

if not demo then
    print("TFT144 Graphics Demo")

    dofile("lib-TFT144.lua")

    tmr.alarm(5, 3000, 0, function() demo=1 dofile(proj..".lua") end)
    return

end


function rnd(x)
    return math.floor(math.random()*x)
end


disp:clearScreen()

if demo ==1 then

    print("Hello")

    disp:setFont(ucg.font_ncenR12_tr);
    disp:setColor(255, 255, 255);
    disp:setColor(1, 255, 0,0);


    disp:setPrintPos(0, 25)
    disp:print("Hello World!")



elseif demo == 2 then

    print("Gradient Box...")


    disp:setColor(0, 0, 255, 0)
    disp:setColor(1, 255, 0, 0)
    disp:setColor(2, 0, 0, 255)
    disp:setColor(3, 255, 255, 255)

    disp:drawGradientBox(0, 0, disp:getWidth(), disp:getHeight())

    disp:setColor(0, 0, 0)
    disp:setPrintDir(0)
    disp:setPrintPos(2, 18)
    disp:print("E Suite")
    disp:setPrintPos(2, 18+20)
    disp:print("GradientBox")




elseif demo==3 then


    print("Text...")


    local x, y, w, h, i
    local m

    disp:setColor(0, 80, 40, 0)
    disp:setColor(1, 60, 0, 40)
    disp:setColor(2, 20, 0, 20)
    disp:setColor(3, 60, 0, 0)
    disp:drawGradientBox(0, 0, 128, 128)

    disp:setColor(255, 255, 255)
    disp:setPrintPos(2,18)
    disp:setPrintDir(0)
    disp:print("Text")

    i = 0
    for i=0, 10 do
        disp:setColor(rnd(255), rnd(255), rnd(255))
        x = rnd(127)
        y = rnd(127)

        disp:setPrintPos(rnd(80)+20, rnd(80)+40)
        disp:setPrintDir(rnd(4))
        i = i + 1
        disp:print("E-Suite")
    end
    disp:setPrintDir(0)



elseif demo==4 then


    print("Fonts...")
    print("   1 Mono transparent\n   2,3 Helvetica transparent\n   4,5 NCEN Solid")

    disp:setColor(0, 0, 40, 80)
    disp:setColor(1, 150, 0, 200)   -- the letter background for solid printing
    disp:setColor(2, 60, 0, 40)
    disp:setColor(3, 0, 160, 160)

    disp:drawGradientBox(0, 0, disp:getWidth(), disp:getHeight())

    disp:setFontMode(ucg.FONT_MODE_TRANSPARENT)

    disp:setColor(255, 255, 255)
    disp:setPrintDir(0)
    disp:setPrintPos(2,17)
    disp:print("Fonts")

    disp:setColor(255, 200, 170)
    disp:setFont(ucg.font_7x13B_tr)
    disp:setPrintPos(2,31)
    disp:print("1 Mono .... 7x13")
    disp:setFont(ucg.font_helvB08_hr)
    disp:setPrintPos(2,45)
    disp:print("2 Abc123 .... Helv08")
    disp:setFont(ucg.font_helvB18_hr)
    disp:setPrintPos(2,68)
    disp:print("3 Helv18")
    --disp:drawString(2,75, 0, "4 ABC abc 123") -- test drawString

    disp:setFontMode(ucg.FONT_MODE_SOLID)

    disp:setColor(255, 200, 170)
    disp:setColor(1, 0, 100, 120)		-- background color in solid mode
    disp:setFont(ucg.font_ncenR14_hr)
    disp:setPrintPos(2,87)
    disp:print("4 ABC ncen14")
    disp:setFont(ucg.font_ncenB24_tr)
    disp:setPrintPos(2,119)
    disp:print("5 Nc24")



    disp:setFontMode(ucg.FONT_MODE_TRANSPARENT)
    disp:setFont(ucg.font_ncenR14_hr)


elseif demo==5 then



    print("Pixel_and_lines...")

    local mx
    local x, xx
    mx = disp:getWidth() / 2
    --my = disp:getHeight() / 2

    disp:setColor(0, 0, 0, 150)
    disp:setColor(1, 0, 60, 40)
    disp:setColor(2, 60, 0, 40)
    disp:setColor(3, 120, 120, 200)
    disp:drawGradientBox(0, 0, disp:getWidth(), disp:getHeight())

    disp:setColor(255, 255, 255)
    disp:setPrintPos(2, 18)
    disp:setPrintDir(0)
    disp:print("Pix&Line")

    disp:drawPixel(0, 0)
    disp:drawPixel(1, 0)
    --disp:drawPixel(disp:getWidth()-1, 0)
    --disp:drawPixel(0, disp:getHeight()-1)

    disp:drawPixel(disp:getWidth()-1, disp:getHeight()-1)
    disp:drawPixel(disp:getWidth()-1-1, disp:getHeight()-1)


    x = 0
    while x < mx do
        xx = ((x)*255)/mx
        disp:setColor(255, 255-xx/2, 255-xx)
        disp:drawPixel(x, 24)
        disp:drawVLine(x+7, 26, 13)
        x = x + 1
    end


elseif demo==6 then



    print("Color_test...")

    local mx
    local c, x
    mx = disp:getWidth() / 2
    --my = disp:getHeight() / 2

    disp:clearScreen()

    disp:setColor(255, 255, 255)
    disp:setPrintPos(2,18)
    disp:setPrintDir(0)
    disp:print("Color Test")

    disp:setColor(0, 127, 127, 127)
    disp:drawBox(0, 20, 16*4+4, 5*8+4)

    c = 0
    x = 2
    while c < 255 do
        disp:setColor(0, c, c, c)  -- white grey shades
        disp:drawBox(x, 22, 4, 8)
        disp:setColor(0, c, 0, 0)   -- red shades
        disp:drawBox(x, 22+8, 4, 8)
        disp:setColor(0, 0, c, 0)  -- green shades
        disp:drawBox(x, 22+2*8, 4, 8)
        disp:setColor(0, 0, 0, c)   -- blue shades
        disp:drawBox(x, 22+3*8, 4, 8)
        disp:setColor(0, c, 255-c, 0)   -- green to red
        disp:drawBox(x, 22+4*8, 4, 8)
        c = c + 17
        x = x + 4
    end



elseif demo==7 then


    print("Boxes...")

    local x, y, w, h


    disp:setColor(0, 0, 40, 80)
    disp:setColor(1, 60, 0, 40)
    disp:setColor(2, 128, 0, 140)
    disp:setColor(3, 0, 128, 140) 
    disp:drawGradientBox(0, 0, 128, 128)

    disp:setColor(255, 255, 255)
    disp:setPrintPos(2,18)
    disp:setPrintDir(0)
    disp:print("Boxes")



    for i=1, 12  do
        disp:setColor(rnd(240), rnd(240), rnd(240))
        w = rnd(60)+2
        h = rnd(60)+2
        x = rnd(90)
        y = rnd(80)+20
      
        disp:drawBox(x, y, w, h)
    end



elseif demo==8 then


    print("Triangles...")


    disp:setColor(255, 255, 255)
    disp:setPrintPos(2, 18)
    disp:print("Triangle")


    for i = 0, 12 do
        disp:setColor(rnd(255), rnd(255), rnd(255))

        disp:drawTriangle(
            bit.rshift(rnd(255) * (disp:getWidth()), 8),
            bit.rshift(rnd(255) * (disp:getHeight()-20), 8) + 20,
            bit.rshift(rnd(255) * (disp:getWidth()), 8),
            bit.rshift(rnd(255) * (disp:getHeight()-20), 8) + 20,
            bit.rshift(rnd(255) * (disp:getWidth()), 8),
            bit.rshift(rnd(255) * (disp:getHeight()-20), 8) + 20
        )

        tmr.wdclr()
    end


elseif demo==9 then

    print("FIN")

    disp:setFont(ucg.font_ncenR12_tr);
    disp:setColor(255, 255, 255);
    disp:setColor(1, 255, 0,0);


    disp:setPrintPos(0, 25)
    disp:print("FIN")
    demo=nil
    return

end

tmr.alarm(5, 3000, 0, function() demo=demo+1 dofile(proj..".lua") end)

-- this file could be cleaned up a lot. A BIG lot! 
-- But it works as a quick demo. "Aint broke ..."
