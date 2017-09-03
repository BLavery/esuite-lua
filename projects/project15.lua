print("Project15: Blynk accelerometer from phone")
 
vw_cb = function(cmd)
    pin = tonumber(cmd[2])  -- ALL vpin "vw" messages arrive here. What vpin is this packet?
    if pin == 13 then   -- v13 = accel
        xx=tonumber(cmd[3])
        yy=tonumber(cmd[4])
        zz=tonumber(cmd[5])
        print("pitch", axl.pitch(yy,zz), "roll", axl.roll(xx,zz))
    end
    if pin == 14 then  -- v14 = light
        ll = cmd[3]
        print("light level", ll)
    end
end
 
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
b=blynk.new (token, function(b) b:on("vw", vw_cb) end ):connect()

dofile("lib-ACCEL.lua") -- provides the pitch/roll maths


-- at phone, accelerometer vpin 13, 1 sec
-- also (incidentlally) a light sensor on V14, 1/sec
