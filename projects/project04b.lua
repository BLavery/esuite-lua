print("Project04: Accelerometer to Blynk")
 

dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' ) 
b=blynk.new (token, false):connect() -- no autogpio

dofile("lib-OLED.lua") -- implicitly starts i2c and sets sda scl

-- some "builds" of nodemcu lua image use "old" init(), some use new setup() syntax:
if adxl345.setup then
    adxl345.setup()  
else
    adxl345.init(sda or 2,scl or 1)  
end
dofile("lib-ACCEL.lua")

tmr.alarm(2, 3000, 1, function()
    local x,y,z = adxl345.read()
    --print(string.format("X = %d, Y = %d, Z = %d", x, y, z))
    local pitch = axl.pitch(y,z)
    local roll = axl.roll(x,z)
    b:write("vw", 5, pitch) 
    b:write("vw", 6, roll)
    oled('y', {"P "..pitch, "R "..roll})
    
end )


-- at ESP8266 we have an ADXL345 accelerometer and OLED display on I2C (pins 2,1)
-- at phone, use two GAUGE widgets, 
--        listening on vpin5 (pitch) and vpin6 (roll), scaled -180 to +180, "PUSH" (ie no polling timer)
