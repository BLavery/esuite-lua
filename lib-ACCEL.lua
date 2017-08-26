-- this file just for roll/pitch
-- in your project, use inbuilt adxl functions of nodemcu

-- nodemcu lua has no math.atan functions. We need to code our own!
                
function math_atan (X0)
    -- https://stackoverflow.com/questions/11930594/calculate-atan2-without-std-functions-or-c99
    -- excellect formula for 0 - 45degr [ie atan(x) for x<1] but runs away for x very large
    -- but we can cheat using symmetry of atan(x) and atan(1/x) around 45degr (0 - 45 - 90)
    local X = X0
    local c = (1 + math.sqrt(17)) / 8
    if X0 < 0 then X = -X0 end
    if X0 > 1  then X = 1/X end
    local A =  (c * X + X*X + math.pow(X,3)) / ( 1 + (c + 1) * X + (c + 1) * X*X + math.pow(X,3)) * math.pi/2
    if X0 > 1  then A = math.pi/2 -A end
    if X0 < 0 then A = -A end
    return A
    -- in radian
end 

function math_atan2(AW,AZ)
    local A = math_atan(AW/AZ)
    -- https://en.wikipedia.org/wiki/Atan2#Definition
    if AZ>0 then return A end
    if AZ<0 then 
        if AW>=0 then return A + math.pi end
        return A - math.pi
    end
    if AW>0 then return math.pi / 2 end
    if AW<0 then return (-math.pi/2) end
    return 0 -- undef?? 
    -- in radian
end

function axl_roll(ax , az)
    return - math.floor(180/math.pi*math_atan2(ax, az))
    -- in integer degrees
end

function axl_pitch(ay , az)
    return math.floor(180/math.pi*math_atan2(ay, az))
    -- in integer degrees
end

