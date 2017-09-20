-- D1 Mini 64x48 oled

sda = 2  -- fixed
scl = 1
local tstamp=0   -- v 0.6

function oled(style, str, pass)
    if not pass then  -- this is a fresh oled command 
        tstamp=tmr.now()
        disp:firstPage() -- 900 usec
        node.task.post( function() oled(style, str, 1) end )
        return
    end
    -- can comment out any unwanted of b y m j sections below if you need to save mem
    
    if ts ~= tstamp then -- a fresh oled() has come in before we finished this seq
        return -- abandon seq    v 0.6
    end

    if style=='m' then  -- messagebox
         -- str={heading, +3 msg lines} as TABLE
         -- USE: oled("m",{"WARNING !","", "IP Address ",wifi.sta.getip()})
         --disp:setScale2x2()
         disp:drawStr(5, 0, string.rep(" ", (9-string.len(str[1]))/2)..str[1])
         --disp:undoScale()
         disp:drawRFrame(0, 10, 64, 38, 6)
         disp:drawStr(2, 13, str[2])
         disp:drawStr(2, 25, str[3])
         disp:drawStr(2, 37, str[4])

    elseif style == 'y' then   -- yell, big font
         -- str={2 msg lines} as table
         -- USE: oled("y", {"STOP", "WRONG WAY"})
         disp:setScale2x2()
         disp:drawStr(0, 0, str[1])
         disp:drawStr(0, 12, str[2])
         disp:undoScale()


    

    elseif style == 'b' then   -- value bar
         -- param={heading, percent} as table
         -- USE: oled("b",{"Temp",17})
         disp:setScale2x2()
         disp:drawStr(3, 0, str[1])
         disp:undoScale()
         disp:drawRFrame(0, 24, 64, 7, 1)
         disp:drawBox(0, 24, 64*str[2]/100, 7)
         disp:setScale2x2()
         disp:drawStr(12, 16, str[2])



    elseif style == 'j' then   -- 4 line journal
         -- str= 1 new journal line as string
         -- USE: oled("j","new entry")
         -- if new string parameter is actually == nil, clear the journal
         if pass == 1 then
            table.remove(Jnl,1)
            table.insert(Jnl,str)
         end
         if str == nil then Jnl = {"","","",""} end
         disp:drawRFrame(0, 0, 64, 48, 4)
         disp:drawStr(2, 6, Jnl[1])
         disp:drawStr(2, 16, Jnl[2])
         disp:drawStr(2, 26, Jnl[3])
         disp:drawStr(2, 36, Jnl[4])



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
    local addrs = 0x3c  -- oled  ssd1306
    i2c.setup(0, sda, scl, i2c.SLOW)  -- sda D1 scl D2  - recommended for devkit 1.0  (use 3,4 for esp-01)
    i2c.start(0)
    local c=i2c.address(0, addrs ,i2c.TRANSMITTER)
    i2c.stop(0)
    if c then 
        disp = u8g.ssd1306_64x48_i2c(addrs) -- d1 mini shield 64x48 pixels
        disp:setFont(u8g.font_6x10)
        --disp:setFontRefHeightExtendedText()
        --disp:setDefaultForegroundColor()
        disp:setFontPosTop()
        Jnl={"","JNL","",""}  -- global/persistent
        node.task.post(0, function() 
             oled('m', {"E-SUITE", wifi.sta.gethostname(),string.sub(Time and Time() or " ",1,8),string.sub(wifi.sta.getip(),5)}) 
        end )
    end 
end

if not disp then   -- replace oled() (save mem). now will simply fail silently if display is not installed
    oled=nil
    function oled()  return end
end

-- v 0.6     20 sept 2017 - abandon sequence if another has been started
-- takes abt 0.5 secs per screenful. More frequent oled updates are not a crash, but do keep esp too busy 
