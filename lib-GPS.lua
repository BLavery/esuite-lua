
if not math.sin then dofile("lib-MATH.lua") end


gps={ lat0=0, long0=0}

function gps.Ref(lat, long)  -- in degrees
    gps.lat0=lat * math.rad
    gps.long0=long * math.rad
end

function gps.Distance(lat, long)  -- in degrees
    local lat1 = lat  * math.rad
    local long1 = long * math.rad
    local R = 6371 -- Radius of the earth in km
    local dLat = lat1-gps.lat0
    local dLon = long1-gps.long0
    local a = math.sin(dLat/2) * math.sin(dLat/2) + math.cos(gps.lat0) * math.cos(lat1) * math.sin(dLon/2) * math.sin(dLon/2)
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)) 

    local direc  = math.atan2(math.sin(dLon)*math.cos(lat1), math.cos(gps.lat0)*math.sin(lat1)-math.sin(gps.lat0)*math.cos(lat1)*math.cos(dLon))

    return R*c, ((direc / math.rad) + 360) % 360  -- km, degrees
end

