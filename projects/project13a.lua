print("project13a")

dofile("lib-STEPPER.lua")

stp1=Stepper.new(4) -- create stepper object on pins 4-7
stp1:run(1, 2, 100) -- Simply runs 100 steps forward and stops.


