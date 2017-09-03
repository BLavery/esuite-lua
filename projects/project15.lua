print("Project15: Blynk accelerometer from phone")
 
vw_cb = function(cmd)
    pin = tonumber(cmd[2])
    if pin == 13 then 
        xx=tonumber(cmd[3])
        yy=tonumber(cmd[4])
        zz=tonumber(cmd[5])
        print("pitch", axl.pitch(yy,zz), "roll", axl.roll(xx,zz))
    end
end
 
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
b=blynk.new (token, function(b) b:on("vw", vw_cb) end ):connect()

dofile("lib-ACCEL.lua") -- provides the pitch/roll maths


-- at phone, accelerometer vpin 13, 1 sec
