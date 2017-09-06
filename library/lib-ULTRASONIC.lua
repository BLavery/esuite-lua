
Sonar = {}
Sonar.__index = Sonar
Sonar.calibration = 57

function Sonar.new(TrigPin, EchoPin, EchoLED)  -- optional led
    local self = setmetatable({}, Sonar)
    gpio.mode(TrigPin, gpio.OUTPUT)  
    self.TrigPin = TrigPin
    gpio.mode(EchoPin, gpio.INT)   
    self.EchoPin = EchoPin
    if EchoLED then
        gpio.mode(EchoLED, gpio.OUTPUT) 
        self.EchoLED = EchoLED  
    end
    self.distance = 0
    self.timestamp = 0
    return self
end




function Sonar.run(self, msecs)

    function echo_cb(level, when)
        if level == 1 then 
            self.t0 = when 
            if self.EchoLED then gpio.write(self.EchoLED,0) end  -- led assumed pulldown
        end
        if level == 0 and self.t0 ~= 0 then
            d = math.floor((when - self.t0) / Sonar.calibration)

            if d<200 then self.distance = d end  -- larger are error
            gpio.trig(self.EchoPin)
            self.t0 = 0
            self.timestamp = when
            if self.EchoLED then gpio.write(self.EchoLED,1) end
        end
    end
    
    function restart()
        gpio.trig(self.EchoPin)
        self.t0 = 0
        gpio.write(self.TrigPin, 1)
        tmr.delay(8)
        if self.EchoLED then gpio.write(self.EchoLED,1) end
        gpio.trig(self.EchoPin, "both", echo_cb)
        gpio.write(self.TrigPin, 0)
    end
    
    self.timr = tmr.create()
    tmr.alarm(self.timr, msecs and msecs or 2000, tmr.ALARM_AUTO, restart)
    return self
end



function Sonar.read (self)
    --print("read")
    return self.distance, self.timestamp
end




