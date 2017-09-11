print("Project 22: Thingspeak adxl345")

-- adxl345 and oled on i2c
-- ESP publishes pitch & roll every 5 mins to thingspeak

dofile("lib-OLED.lua")

if adxl345.setup then
    adxl345.setup()  
else
    adxl345.init(sda or 2,scl or 1)  
end
dofile("lib-ACCEL.lua")

dofile("lib-THINGSPEAK.lua")

_MINS=60000
_SECS=1000

tmr.alarm(2, 40*_SECS, 1, function() 
    local x,y,z = adxl345.read()
    local pitch = axl.pitch(y,z) 
    local roll = axl.roll(x,z)
    postThingSpeak(5, roll, "Roll")
    tmr.alarm(3, 15*_SECS, 0, function() postThingSpeak(4, pitch, "Pitch") end )
    -- thingspeak limit: must wait 15 secs between postings.

    oled("m", {string.sub(Time(), 1, 5), "ROLL "..tostring(roll), "PITCH "..tostring(pitch), ""})
end )

dofile("lib-TELNET.lua")  -- optional
