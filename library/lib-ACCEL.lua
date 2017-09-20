-- this file just for roll/pitch
-- in your project, use inbuilt adxl functions of nodemcu
if not math.sin then dofile("lib-MATH.lua") end

axl={}
function axl.roll(ax , az)
    return - math.floor(math.atan2(ax, az)/math.rad)
    -- in integer degrees
end

function axl.pitch(ay , az)  -- the simple version . good nough for many purposes
    return math.floor(math.atan2(ay, az)/math.rad)
    -- in integer degrees +-180 degr
end

--[[
function axl.pitch(ax, ay , az)  -- the "correct" version
    local roll = -math.atan2(ax, az)
    p= math.atan(ay / (ax * math.sin(roll) + az * math.cos(roll)))  --   +-90 degr
    return math.floor(p / math.rad)
    -- eg see  https://www.phidgets.com/docs/Magnetometer_Primer
end
--]] 
