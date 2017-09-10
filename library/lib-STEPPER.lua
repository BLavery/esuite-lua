
local states8 = {  -- table shows 8 steps. Double-stepping is allowed, then uses only states 1 3 5 7
 {1,0,0,1},
 {1,0,0,0},
 {1,1,0,0},
 {0,1,0,0},
 {0,1,1,0},
 {0,0,1,0},
 {0,0,1,1},
 {0,0,0,1},
}
Stepper = {}
Stepper.__index = Stepper

-- halfstep true/false
function Stepper.new(pin1)
    local self = setmetatable({}, Stepper)
    self.pin1 = pin1
    self.posn = 0
    self.stepsleft = 0
    self.phase = 0   
    for c=0, 3 
    do
        gpio.mode (pin1+c, gpio.OUTPUT)
        gpio.write(pin1+c, gpio.LOW)
    end
    self.timer = tmr.create()
    return self
end

-- tmr.alarm() callback passes only the timer-id as function parameter (nodelua constraint)
-- but we have kept a key-value lookup table from which we can retrieve stepper object id.

function Stepper.step1(self)
    -- execution time abt 1 mSec, or abt 22mSec for mcp23017 extended GPIOs!
    -- and fastest timer is 1mSec. So best performance is 500 steps or doublesteps / sec.
    if self.stepsleft>0 then self.stepsleft = self.stepsleft-math.abs(self.dir) end
    local left = self.stepsleft
    if self.limitpin and (gpio.read(self.limitpin) == self.pol) then self.stepsleft=0 end
    self.posn = self.posn+self.dir
    if self.posn%2==1 and math.abs(self.dir)==2 then self.posn = self.posn+1 end -- doublestep resync
    local phase = (self.posn % 8)+1
    local c for c=0, 3 do
        gpio.write(self.pin1+c, states8[phase][1+c])
    end

    if self.stepsleft==0 or self.stepsleft==(-1) then
        for c=0, 3 do
            gpio.write(self.pin1+c, 0)
        end
        if self.callback then self.callback(self, left) end
        return
    end
    self.timer:alarm(self.speed, 0,  function(t) self:step1() end) 
    -- manually rearm timer. This way we can't accumulate a stack of pending callbacks
    -- which can occur using a repeating timer at full stepper speed
    -- and which will cause a crash
end

-- speed is ms per step, min 1   
-- steps: max. stepsleft reduces until 0.  if <=(-2), no limit
-- dir -1=rev 1=fwd 0=stop -2=rev/dblstep or 2 =fwd/dblstep 
-- optional callback on stop
-- will stop if limitpin goes to "polarity"

function Stepper.run(self, dir, speed, steps, callback, limitpin, polarity )
    if dir==0 then tmr.stop(self.timer) return end
    self.limitpin = limitpin 
    self.dir = dir  -- -2 to +2
    self.callback = callback
    speed = speed or 2
    self.speed = (speed<3) and 1 or (speed-1) -- min 1, otherwise as requested less 1 (as step task is 1 msec)
    self.stepsleft=steps or (-2)
    self.pol = polarity or 1 
    if limitpin then 
        gpio.mode (limitpin, gpio.INPUT, gpio.PULLUP) 
    end
    self.timer:alarm( 1, 0, function(t) self:step1() end) 
print("run")
end


