
if not math.sin then dofile("lib-MATH.lua") end

local lat0, long0

function gpsRef(lat, long)  -- in degrees
    lat0=lat * math.rad
    long0=long * math.rad
end

function gpsDistance(lat, long)  -- in degrees
    local lat1 = lat  * math.rad
    local long1 = long * math.rad
    local R = 6371 -- Radius of the earth in km
    local dLat = lat1-lat0
    local dLon = long1-long0
    local a = math.sin(dLat/2) * math.sin(dLat/2) + math.cos(lat0) * math.cos(lat1) * math.sin(dLon/2) * math.sin(dLon/2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)) 

    local direc  = math.atan2(math.sin(dLon)*math.cos(lat1), math.cos(lat0)*math.sin(lat1)-math.sin(lat0)*math.cos(lat1)*math.cos(dLon))

    return R*c, ((direc / math.rad) + 360) % 360  -- km, degrees
end

