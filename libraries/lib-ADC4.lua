-- PCF8591 module for ESP8266 with nodeMCU

-- On YL-40 board
-- 0 = photoresistor
-- 1 = nothing on-board
-- 2 = thermistor 
-- 3 = variable resistor

local device = 0x48 -- PCF8591 address, might vary from 0x48 to 0x4F

i2c.start(0)
local c=i2c.address(0, device ,i2c.TRANSMITTER) -- probe for pcf8591 installed?
i2c.stop(0)
if c then 
    print "PCF8591 found"
    adc = clone(adc) -- a ram-based clone

    -- read adc register 0 to 3
    function adc.read(reg)
      if reg <8 then return adc.parent.read(reg) end
      
      i2c.start(0)
      i2c.address(0, device, i2c.TRANSMITTER)
      i2c.write(0, 0x00 + reg-8)
      i2c.stop(0)
      i2c.start(0)
      i2c.address(0, device, i2c.RECEIVER)
      local data = i2c.read(0, 2)
      i2c.stop(0)
      return string.byte(data, 2)
    end

    -- write dac register
    function adc.write(val)
      i2c.start(0)
      i2c.address(0, device, i2c.TRANSMITTER)
      i2c.write(0, 0x40)
      i2c.write(0, val)
      i2c.stop(0)
    end

else
    print("No PCF")
end
