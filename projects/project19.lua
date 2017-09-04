print("Project19 - tone on a passive beeper")
-- suits one beeper

dofile("lib-TONE.lua")

pin=6

function fin1()
    tone(pin, 200, 2000)                                -- followed by this second
end


tone(pin, 860, 2000, fin1)  -- occurs first
