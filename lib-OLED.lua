-- SETUP the oled connections:
-- INCLUDE AS DESIRED IN YOUR PROJECT FILE

sda = sda or 2
scl = scl or 1

-- the "REGULAR" connection for oled's VCC pin is to go to "3.3". But power needed is small.
-- OPTIONAL: set a GPIO output as controllable power pin (3.3V) to the oled.
-- This way, oled goes off when power down/deepsleep
--gpio.mode(7,gpio.OUTPUT)
--gpio.write(7,1)

function oled(style, str, pass)
    if not pass then  -- this is a fresh oled command 
        disp:firstPage() -- 900 usec
        node.task.post( function() oled(style, str, 1) end )
        return
    end
    -- can comment out any unwanted of b y m j sections below if you need to save mem
    
    if style=='m' then  -- messagebox
         -- str={heading, +3 msg lines} as TABLE
         -- USE: oled("m",{"WARNING !","", "IP Address ",wifi.sta.getip()})
         disp:setScale2x2()
         disp:drawStr(5, 0, string.rep(" ", (9-string.len(str[1]))/2)..str[1])
         disp:undoScale()
         disp:drawRFrame(0, 18, 128, 46, 9)
         disp:drawStr(5, 23, string.rep(" ", (20-string.len(str[2]))/2)..str[2])
         disp:drawStr(5, 36, string.rep(" ", (20-string.len(str[3]))/2)..str[3])
         disp:drawStr(5, 49, string.rep(" ", (20-string.len(str[4]))/2)..str[4])

    elseif style == 'y' then   -- yell, big font
         -- str={2 msg lines} as table
         -- USE: oled("y", {"STOP", "WRONG WAY"})
         disp:setScale2x2()
         disp:drawStr(2, 0, string.rep(" ", (10-string.len(str[1]))/2)..str[1])
         disp:drawStr(2, 20, string.rep(" ", (10-string.len(str[2]))/2)..str[2])
         disp:undoScale()


    

    elseif style == 'b' then   -- value bar
         -- param={heading, percent} as table
         -- USE: oled("b",{"Temp",17})
         disp:setScale2x2()
         disp:drawStr(5, 0, string.rep(" ", (10-string.len(str[1]))/2)..str[1])
         disp:undoScale()
         disp:drawRFrame(0, 30, 128, 9, 1)
         disp:drawBox(0, 30, 128*str[2]/100, 9)
         disp:drawStr(60, 45, str[2])



    elseif style == 'j' then   -- 4 line journal
         -- str= 1 new journal line as string
         -- USE: oled("j","new entry")
         -- if new string parameter is actually == nil, clear the journal
         if pass == 1 then
            table.remove(Jnl,1)
            table.insert(Jnl,str)
         end
         if str == nil then Jnl = {"","","",""} end
         disp:drawRFrame(0, 0, 128, 64, 4)
         disp:drawStr(5, 5, Jnl[1])
         disp:drawStr(5, 19, Jnl[2])
         disp:drawStr(5, 33, Jnl[3])
         disp:drawStr(5, 46, Jnl[4])



    end
    
    if disp:nextPage() then     -- 29 msec
        node.task.post( function() oled(style, str, 2) end )   --  schedule again for another pass
    end
end
-- oled(style, txt-table) is called by user to start new screen output.
-- oled(style, txt, pass) is then automatically called about 7 times, to "paint" the pixels in segments
-- each individual segment call is abt 55 mSec, and complete repaint is abt 450 mSec
-- a new user call before one full repaint is complete will corrupt display.

-- Are u8g oled driver and our needed font installed:
if u8g.font_6x10 then
    local addrs = 0x3c  -- oled 96 ssd1306
    i2c.setup(0, sda, scl, i2c.SLOW)  -- sda D1 scl D2  - recommended for devkit 1.0  (use 3,4 for esp-01)
    i2c.start(0)
    local c=i2c.address(0, addrs ,i2c.TRANSMITTER)
    i2c.stop(0)
    if c then 
        disp = u8g.ssd1306_128x64_i2c(addrs) 
        disp:setFont(u8g.font_6x10)
        --disp:setFontRefHeightExtendedText()
        --disp:setDefaultForegroundColor()
        disp:setFontPosTop()
        Jnl={"","JNL","",""}  -- global/persistent
        node.task.post(0, function() 
             oled('m', {"E-SUITE", wifi.sta.gethostname(),Time and Time() or "",wifi.sta.getip()}) 
        end )
    end 
end

if not disp then   -- replace oled() (save mem). now will simply fail silently if display is not installed
    oled=nil
    function oled()  return end
end

