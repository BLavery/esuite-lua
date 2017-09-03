print("Project14: Blynk gps")
-- this project shows distance and bearing of blynk on smartphone
-- reference brisbane

vw_cb = function(cmd)
    pin = tonumber(cmd[2])
    if pin == 11 then 
        lat=cmd[3]
        lon=cmd[4]
        d,b = gps.Distance(lat,lon)
        print (math.floor(d),"km", math.floor(b), "degr (from Brisbane)")
    end
end
 
setup_cb = function(b)
    b:on("vw", vw_cb)
end 
 
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
b=blynk.new (token, setup_cb):connect()

dofile("lib-GPS.lua")
gps.Ref(-27.47,153.03) -- brisbane qld australia

-- at phone, gps vpin 11
