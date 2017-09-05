-- this file just for roll/pitch
-- in your project, use inbuilt adxl functions of nodemcu
if not math.sin then dofile("lib-MATH.lua") end

axl={}
function axl.roll(ax , az)
    return - math.floor(math.atan2(ax, az)/math.rad)
    -- in integer degrees
end

function axl.pitch(ay , az)
    return math.floor(math.atan2(ay, az)/math.rad)
    -- in integer degrees
end

