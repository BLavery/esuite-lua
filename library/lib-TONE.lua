-- simple/simplistic tone for passive beeper ("YL-44")
local tonetimer=tmr.create()

function tone(pin, hz, dur, callback) -- in msec
    gpio.mode(pin,gpio.OUTPUT)  
    pwm.setup(pin, hz, 500)  
    pwm.start(pin)                                                          
    tonetimer:alarm(dur, 0, function()
            pwm.stop(pin)
            pwm.close(pin)   
            if callback then callback() end   -- optional callback at finish
    end)
end
