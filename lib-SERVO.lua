--  SERVO
--      V1.00     - used pwm


-- RC servo, 3 pin connector.
-- RED = nominally +4.5 (but +5V is OK, so we connect to that)    Sometimes a red/orange  
--         RED + wire is usually the centre one. But not always - depends on manufacturer. Be careful.
-- BLACK = GND   (sometimes brown)  
-- 3rd wire (ORANGE or YELLOW or WHITE) = pulse signal (from GPIO pin)

-- Reference:  https://www.princeton.edu/~mae412/TEXT/NTRAK2002/292-302.pdf

-- "set()" takes values 0 to 100. Not degrees. Setting <--> degrees depends on scaling. 
-- Available full scale movement is likely abt 170-180 degr.

Servo = {}
Servo.__index = Servo

function Servo.set(self, val)
    if self.pin <0 then return end   -- not init
    self.value = val  
    if val >=0 and val <=100 then
        gpio.mode(self.pin,gpio.OUTPUT)  
        pwm.setup(self.pin,75,115+(val-50)*self.scale/100) 
        -- 75 Hz probably as fast as safe?? Then duty cycle 115/1024 is midpoint (1500 uSec pulse) 
        pwm.start(self.pin)  
        --print(self.pin,val)
    else
        pwm.stop(self.pin)  
        pwm.close(self.pin)
        gpio.write(self.pin, 1)
        --print ("off")
    end 
end

function Servo.new(pin, scale)
    local self = setmetatable({}, Servo)
    self.value = -2   -- == stopped
    self.pin = pin
    self.scale = scale and scale or 130 -- Can adjust this for max sweep of servo position over web buttons 0 to 100. 
    -- max scale value likely abt 140. But as low as 80 may be needed to avoid over-scan on some servos.
    return self
end

function Servo.get(self)
    return self.value
end

