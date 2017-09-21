if Time then return end -- no re-entry

local no_project_yet = true  -- v0.6
local no_sync_yet = true  -- v0.6

sntp.sync({'0.au.pool.ntp.org', '1.au.pool.ntp.org', '2.au.pool.ntp.org', '3.au.pool.ntp.org'}, -- v0.6, alter if wanted

      -- following is the SUCCESS callback of sync
      function()   -- importantly, the rtc gets implicitly set with internet time
        if no_sync_yet then
            print('Time Sync ', Time()) 
            no_sync_yet = nil
        end
        if no_project_yet then 
            no_project_yet=nil 
            node.task.post( function() dofile(proj..".lua") end ) 
        end
      end,

      function() -- this is the FAIL callback of sync
          if rtctime.get() < 1400000000 then  -- do we still have a "reasonable" time? from dsleep??
              rtctime.set(0,0) -- otherwise kickstart rtc ticking with a "primeval" time
          end
          if no_project_yet then 
            print('Initial time sync failed!')
            no_project_yet=nil 
            node.task.post( function() dofile(proj..".lua") end ) 
          end
      end,
      
      true -- v 0.6   silent sync autorepeat to occur every 15 minutes
)


function Time(tz,secs)
    tz = tz and tz or 10-- Brisbane default
    secs = secs and secs or rtctime.get() -- current time or specified timestamp
    local t = rtctime.epoch2cal( secs +(tz*3600))
    return string.format("%02d:%02d:%02d %02d/%02d/%d",t['hour'],t['min'],t['sec'],t['day'],t['mon'],t['year'])
end

-- v0.6  21 Sept 2017   added autorepeat
