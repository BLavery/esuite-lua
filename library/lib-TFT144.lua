-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/ucglib/GraphicsTest.lua

-- rst pin tied +3.3
-- cs pin tied gnd
-- dc/a0 def d4 but can be other pin: define _A0=2 say before loading lib
-- clk d5
-- din d7
-- vcc to +5
-- led to +3.3  - instead you could use a gpio to turn on & off?

if (not spi) or (not ucg) or not ucg.ili9163_18x128x128_hw_spi then
    print("No TFT144 support in your lua bin") 
    return
end

spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
disp = ucg.ili9163_18x128x128_hw_spi(8, _A0 or 4)
_A0=nil
gpio.mode(8, gpio.INPUT, gpio.INPUT) -- then allow d8 for re-use


Disp={}
function Disp.yell(s1, s2, s3, r, g, b, rb, gb, bb)  -- add own spacing if want centred!
    disp:setColor( rb or 0, gb or 0, bb or 0)
    disp:drawBox(0,0,128,128)
    disp:setFont(ucg.font_helvB18_hr)
    disp:setColor(r or 255, b or 30, g or 30)
    disp:setPrintPos(0, 35)  disp:print(s1 or "")
    disp:setFont(ucg.font_ncenB24_tr)
    disp:setPrintPos(0, 70)  disp:print(s2 or "")
    disp:setPrintPos(0, 100)  disp:print(s3 or "")
end

function Disp.box(hdr, m1,m2,m3,m4, r,g,b, rb,gb,bb)
    disp:setColor( rb or 0, gb or 0, bb or 0)
    disp:drawBox(0,0,128,128)    
    disp:setFont(ucg.font_ncenR14_hr)
    disp:setColor(r or 255, g or 0, b or 0)
    disp:setPrintPos(0, 18)  disp:print(hdr or "")
    disp:drawRFrame(0,25,127,102, 8)
    disp:setFont(ucg.font_helvB10_hr)
    disp:setColor(255, 255, 255)
    disp:setPrintPos(5, 48)  disp:print(m1 or "")
    disp:setPrintPos(5, 68)  disp:print(m2 or "")
    disp:setPrintPos(5, 88)  disp:print(m3 or "")
    disp:setPrintPos(5, 108)  disp:print(m4 or "")
end

disp:begin(ucg.FONT_MODE_TRANSPARENT)
disp:setRotate270() -- only 270 mode works ok on black brd. ALL work on red brd, 
                    -- so you could change this (omit or 180 or 90)
Disp.box("     E Suite.", wifi.sta.getip(), wifi.sta.gethostname(), nil, Time():sub(1,14))


-- comment: ucglib implementation is buggy and scales poorly to esp8266.
-- few fonts. no large monospaced font
-- setScale2x2() undoScale() crashes
-- no ucg bmp image draw function

if DRAW_BMP then -- only loaded if DRAW_BMP is declared in project -- fn consumes abt 2500 bytes!
    -- save BMP with gimp.  24byte format, no extras
    -- careful about files. This fn has file open over duration of bmp drawing. Object model. 
    
    local function paint1line(yi, w, x, y,f) -- paints one line of image
            local xi , rgb
            rgb = f:read(w*3)  -- buffer vbl abt 400 bytes max for 128 width
            for xi =0, w-1 do
                disp:setColor(rgb:sub(3+3*xi,3+3*xi):byte(), rgb:sub(2+3*xi,2+3*xi):byte(), 
                         rgb:sub(1+3*xi,1+3*xi):byte())
                disp:drawPixel(xi+(x or 0), yi+(y or 0))
                if (xi+1)%7 ==0 then tmr.wdclr() end -- abt 30 msec point
            end
            xi=3*w
            if (xi%4)>0 then f:read((-xi)%4) end -- burn 1-3 bytes of padding (bmp spec)
            if yi >0 then 
                node.task.post(0, function() paint1line(yi-1, w, x, y,f) end ) -- continue to next line
            else
                f:close() -- all done
            end
    end
    
    
    function Disp.drawBMP(fn, x, y)  -- imagefilename, x/y to locate image
        local f = file.open(fn, "r") -- file handle/object
        if not f then print(fn .. " N/F") return end
        local fb=f:read(25) -- table of bmp config data
        local w=fb:sub(19,19):byte() 
        local h=fb:sub(23,23):byte() 
        f:seek("set",fb:sub(11,11):byte()) -- start of image data (bmp = bottom line first!)
        node.task.post(function() paint1line(h-1, w, x, y, f) end ) -- paint first line (from bottom) of image
    end
end



