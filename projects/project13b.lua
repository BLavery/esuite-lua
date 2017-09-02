print("project13b")

dofile("lib-STEPPER.lua")

--[[
Stepper1 on pins 4-7 simply runs 100 steps forward and stops.

Stepper on slow pins 15-18 firstly does a "calibration run" backwards until 
limit switch (D3 flash button) is operated.
Then it moves forward 200 steps in double steps.
Its posn reading then should correctly read 200.

--]]

function fin4_cb(stpr, lft)
    print("Fin", stpr.pin1, stpr.posn, lft)
end

function fin15calib_cb(stpr, lft)
    print("Fin calibr", stpr.pin1, "after", stpr.posn, "steps")
    stpr.posn=0 -- reset reference position
    stpr:run(2, 1, 200, fin15b_cb)  -- run again to position 200
end

function fin15b_cb(stpr, lft)
    print("Fin run", stpr.pin1, "Position (calibrated) =", stpr.posn)
end

stp1=Stepper.new(4)
stp1:run(1, 3,100, fin4_cb)
-- run fwd at speed 3steps/sec, stop after 100 steps

stp4=Stepper.new(15)  -- on extended gpios, so will be slow
stp4:run(-1, 1, -2, fin15calib_cb, 3, 0)
-- run backwards at best speed, no step limit, only terminated by limit switch
-- the callback will later run forward again
print("'limit switch' = D3 flash button. Please press.")
