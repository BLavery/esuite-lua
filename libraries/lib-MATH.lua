if math.sin then return end

-- adds new math.xx functions: sin() cos()  atan()  atan2() rad

math=clone(math)

function math.atan (X0)
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

function math.atan2(AW,AZ)
    local A = math.atan(AW/AZ)
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



local function factl(n)
    if n==1 then return 1 end
    return n * factl(n-1)
end

function math.sin(x) -- taylor series. Exc accuracy -PI to +PI.  Ref  https://en.wikipedia.org/wiki/Taylor_series
    x=(x%(2*math.pi)-math.pi)
    local ss=x 
    - math.pow(x,3)/factl(3) 
    + math.pow(x,5)/factl(5) 
    - math.pow(x,7)/factl(7)
    + math.pow(x,9)/factl(9) 
    - math.pow(x,11)/factl(11)
    + math.pow(x,13)/factl(13) 
    - math.pow(x,15)/factl(15)
    return(-ss)  -- minus because we slid graph left by PI
end

function math.cos(x)
    return math.sqrt(1-math.pow(math.sin(x),2))  -- sin^2 + cos^2 = 1
end

math.rad =  math.pi / 180
