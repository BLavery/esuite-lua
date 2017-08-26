local APlist = {
    {"theRiver", "jaxplase"}, 
    {"bluerat", "XX78%sg6"}
}
-- or simply APlist = { "ap", "pw" }

-- wifi.sta.disconnect()   -- uncommect to FORCE connection attempts from the APlist

if #APlist == 2 and APlist[1][1] == nil then APlist = {APlist} end  -- if simple mode, reformat correctly

local station_cfg={}

-- Connect to my wifi
local function connecting()
    local apnum = 1  -- start with first AP listed
    station_cfg.ssid=APlist[1][1]
    station_cfg.pwd=APlist[1][2]
    station_cfg.save=true
    wifi.sta.config(station_cfg)
    print("Connecting to AP " .. station_cfg.ssid  .. " ...")
    tmr.alarm(0, 500, 1, function()
        if wifi.sta.getip()~=nil then
          tmr.stop(1)
          tmr.stop(0)
          print("Connected: " .. wifi.sta.getip())
          if not Time then node.task.post( function() station_cfg=nil dofile("init3-TIME.lua")  end) end
        end
    end)

    tmr.alarm(1, 30000, 1, function()  -- if not connecting after 30 secs, cycle to next AP in list
        if #APlist > 1 then
            apnum = apnum+1
            if apnum > #APlist then apnum = 1 end
            station_cfg.ssid=APlist[apnum][1]
            station_cfg.pwd=APlist[apnum][2]
            wifi.sta.config(station_cfg)
            print("Trying AP " .. station_cfg.ssid .. " ...")
        else
            print("Still trying to connect ...")
        end
    end)
end


if wifi.sta.getip()~=nil then
      -- easy: from prev credentials, it has autoconnected.  We did nothing!
      local ssid = wifi.sta.getconfig()
      print ("Auto-connected "  .. wifi.sta.getip(), ssid)
      if not Time then node.task.post( function() dofile("init3-TIME.lua")  end) end
else
      connecting() -- Not autoconnected, so we need formal connection process
end

-- Note that "normally", any later wifi disconnect (once first connected) will auto-reconnect as available,
--    but only to the earlier used AP, not to any of the alternatives.
-- It is legitimate to "RE"-load this file later, to rescan all AP credentials.
--    Then it's just for wifi resetting, 
--    IE, Doesn't go on again to time & proj sequence on reconnect. Those are already loaded.
-- But there is nothing automatic about invoking such a reload. A "project"-level possibility only.






