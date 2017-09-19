
Gpio={}

Gpio.__index = Gpio

function Gpio.new(p, mode, opt)
    local self = setmetatable({}, Gpio)
    self.pin=p
    self.mode = 0
    if mode == 0 then gpio.mode(p, 0, opt) 
    elseif mode == 1 then gpio.mode(p,1, opt) self.mode = 1 
    else return nil end
    return self
end

function Gpio.write(self, v)
    if self.mode == 1 then gpio.write(self.pin, v) end
end

function Gpio.read(self)
    -- getting errors? Check you use colon not dot as in but3:read() 
    return gpio.read(self.pin)
end



-- abt 1400 bytes
