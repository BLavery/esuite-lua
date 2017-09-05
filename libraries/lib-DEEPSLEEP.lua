-- d1 mini large deepsleep current
-- lolin v3 - low current
-- genuine nodemcu 1.0  large deepsleep current


-- sleeptime: Time in secs for each deep sleep.  MAX allowed = 71 minutes (4260 secs)
-- startType:  def 0: 0=full delayed start each wake, 1 = full start w/o delay
--             3=brief "peep wake" between sleeps, straight to project file 
-- passes: How many successive sleeps before sequence finished? default 1

function DEEPSLEEP(sleeptime, startType, passes)
    passes = passes or 1
    startType = startType or 0
    print("Deep Sleep", passes, "Bye...")
    -- print is an  async process driven by lua engine. hopefully we print before sleeping?

    if writeLog then writeLog("Sleep mins", math.floor(passes * sleeptime / 60)) end
    -- writeLog is not an async job. (I think?)  It's finished now.
    
    rtcmem.write32(20, 123654, sleeptime, startType, passes-1) -- params passed across sleep to wake
    node.task.post(0, rtctime.dsleep(sleeptime*1000000))     -- bye bye (in uSec)
    -- node.task gets lower priority than (background) print from above. 
    -- So this way the print actually happens before sleeping!
end


isDSwake, ds_time, StartType, sleeps2do = rtcmem.read32(20,4) 

if rtcmem.read32(20) ~= 654321 then -- another magic number = was a wakeup from dsleep
    isDSwake, ds_time, StartType, sleeps2do = 0,0,0,0
end

if sleeps2do >0 then  -- we are part-through a sequence of sleeps
    print("Peep only.")
    DEEPSLEEP( ds_time,   -- time of EACH sleep, preserved via rtcmem during last sleep
              sleeps2do==1 and 0 or StartType, 
                    -- "peeping" brief wake?? if more sleeps to come, force full wake on last
              sleeps2do) -- remaining sleeps
              
    return
end

-- rtcmem address usage:
-- 20:  a magic number 123654 (written here, read by next init) or 654321 (written by init, read here)
-- 21:  0 = full start (with delay) at each wake from sleep - default
--      1 = full start (but without delay) at each wake from sleep
--      3 = straight to project at wake between sleeps
-- 22:  deepsleeps are still scheduled
-- 23:  each dsleep time (usecs)


