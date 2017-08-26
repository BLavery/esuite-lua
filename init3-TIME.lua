local is_1st_load = (not Time)

sntp.sync((math.floor(node.random()*10) % 4) .. '.au.pool.ntp.org' , -- choice of 4

      -- following is the SUCCESS callback of sync
      function(sec,usec,server)   -- importantly, the rtc gets implicitly set
        print('Time Sync ', Time())
        if is_1st_load then node.task.post( function() dofile(proj..".lua") end ) end
      end,

      function() -- this is the FAIL callback of sync
          print('Time sync failed!')
          if rtctime.get() < 1400000000 then  -- do we still have a "reasonable" time? from dsleep??
              rtctime.set(0,0) -- otherwise kickstart rtc with a "primeval" time
          end
          if is_1st_load then node.task.post( function() dofile(proj..".lua") end ) end
      end
)

if is_1st_load then 
    function Time(tz,secs)
        tz = tz and tz or 10-- Brisbane default
        secs = secs and secs or rtctime.get() -- current time or specified timestamp
        local t = rtctime.epoch2cal( secs +(tz*3600))
        return string.format("%02d:%02d:%02d %02d/%02d/%d",t['hour'],t['min'],t['sec'],t['day'],t['mon'],t['year'])
    end
end

-- It is legitimate to "RE"-load this file later, to retry time sync.
--    Doesn't go on again to proj sequence. That is already loaded.
-- But there is nothing automatic about invoking such a reload. A "project"-level possibility only.


