


i2c.setup(0,sda or 2,scl or 1,i2c.SLOW)

print("Scanning I2C Bus")
for adr=2,120 do 
     i2c.start(0)
     if i2c.address(0, adr ,i2c.TRANSMITTER) then -- returns true if a device responded at that address
         print("Device found at address "..string.format("%02X",adr))
     end
     i2c.stop(0)
end

-- that's all folks
