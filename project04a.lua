print("Project04: Accelerometer")

-- put override sda /scl here if not 2,1

-- some "builds" of nodemcu lua image use "old" init(), some use new setup() syntax:
if adxl345.setup then
    i2c.setup(0, sda or 2, scl or 1, i2c.SLOW) 
    adxl345.setup()  
else
    adxl345.init(sda or 2,scl or 1)  
end

tmr.alarm(2, 200, 1, function()
    local x,y,z = adxl345.read()
    print(string.format("X = %d, Y = %d, Z = %d", x, y, z))
end )

-- at ESP8266 we have an ADXL345 accelerometer  on I2C (pins 2,1)

