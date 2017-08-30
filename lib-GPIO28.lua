-- gpio functions:         NYT
-- D0 to D8 (or D12) identical to normal.
-- gpio numbers 13 - 28: on mcp23017. Digital I/O only, no interrupt/trig functions.
-- Same syntax.  Eg gpio.mode(17,gpio.OUTPUT [,gpio.PULLUP])  gpio.write(17, gpio.HIGH)

-- Chip address & registers: 
      MCP23017_ADDRESS = 0x20  -- support for one chip only
      MCP23017_IODIRA=0x00     -- 1 = input (default 1) OPPOSITE OF MAIN ESP GPIO!! 
local MCP23017_IPOLA=0x02      -- 1 = inverted inputs (default 0)
      MCP23017_GPPUA=0x0C      -- 1 = pullup enabled (default 0, pullup 1)
      MCP23017_GPIOA=0x12      -- data voltage on pins (as-read input or as-written output)   1=high

function _getBank(pin)
        if pin >7 then return pin-8, 1 else return pin,0 end
end

function _write_reg(register, data8)
      i2c.start(0)
      i2c.address(0, MCP23017_ADDRESS, i2c.TRANSMITTER) 
      i2c.write(0, register)
      if(data8 >= 0) then
        i2c.write(0, data8)
      end
      i2c.stop(0)
end

    -- function for reading byte from the given register
function _read_reg(register)
      _write_reg(register,-1)
      i2c.start(0)
      i2c.address(0, MCP23017_ADDRESS,i2c.RECEIVER)
      local data8=string.byte(i2c.read(0,1))
      i2c.stop(0)
      return data8
end

function _pinWrite(pin, data, register)  
        local bankPin,bank = _getBank(pin)
        local bankVal=_read_reg(register+bank)
        if data == 1 then
            bankVal = bit.set(bankVal, bankPin)
        else  
            bankVal = bit.clear(bankVal, bankPin)
        end  
        _write_reg(register+bank,bankVal)
end

i2c.start(0)
c=i2c.address(0, MCP23017_ADDRESS ,i2c.TRANSMITTER) -- probe for mcp23017 installed?
i2c.stop(0)
if c then 
    print "MCP23017 found"
    _write_reg(MCP23017_IODIRA, 0xFF) -- all pins to input
    _write_reg(MCP23017_IODIRA+1, 0xFF)
    _write_reg(MCP23017_IPOLA, 0x00)   
    _write_reg(MCP23017_IPOLA+1, 0x00)
else
    print("No MCP")
end

local function clone (t) -- deep-copy a table.   Ref https://gist.github.com/MihailJP/3931841
    if type(t) ~= "romtable" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "romtable" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta) 
    return target  
end 
 
gpio_old = gpio -- an alias name for orig gpio function, rom-based
gpio = clone(gpio_old) 
-- gpio is now a cloned table copy in ram, 
-- exc the member functions read() write() etc remain rom based lightfunctions
-- but we can overwrite functions with our own read() etc !

function gpio.read(pin)
        if pin <= 12 then return gpio_old(pin) end  -- orig gpio 0-12: use orig ESP8266 functions
        pin = pin-13                                -- new gpio numbers 13-28 renumbered to 0-15
        local bankPin,bank = _getBank(pin)          -- convert to pin 0-7 and bank 0/1
        return bit.band(bit.rshift(_read_reg(MCP23017_GPIOA+bank),bankPin),0x1)
end

function gpio.write(pin, data)
        if pin <=12 then gpio_old.write(pin,data) return end
        pin = pin-13 
        _pinWrite(pin, data, MCP23017_GPIOA)
end

function gpio.mode(pin, dir, pullup)
        if pin <= 12 then gpio_old.mode(pin, dir, pullup) return end 
        pin = pin-13 
        _pinWrite(pin,1-dir,MCP23017_IODIRA)  -- mcp uses 0=out 1=in opp of usual!        
        if dir == gpio.INPUT and pullup ~= nil then _pinWrite(pin,pullup,MCP23017_GPPUA) end
end
