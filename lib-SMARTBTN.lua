-- On one pin, a button that has 3 (callback) functions for short or 1-sec or 3-sec presses.
-- BL Oct 2015


_tstamps={}
smartButton = function(pin, k0, k1, k3)
     _tstamps[pin+1]=0     
     gpio.mode(pin,gpio.INT)
     gpio.trig(pin, "both",
             function(level)
               local dur = tmr.now() - _tstamps[pin+1]
               _tstamps[pin+1] = tmr.now()
               if gpio.read(pin) == 1 then    -- BUTTON UP?      note "level" seems unreliable
                  if (dur < 500000) then if (k0 ~= nil) then k0() end          -- SHORT
                  elseif (dur < 1800000) then if  (k1 ~= nil) then k1() end    -- 1 Sec
                  elseif (dur < 6000000) then if  (k3 ~= nil) then k3() end    -- 3 sec
                  end
               end
            end 
    )
end
     



