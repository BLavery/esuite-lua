-- lib-LOGGER.lua        ought to be an optional library!
-- INCLUDE AS DESIRED IN YOUR PROJECT FILE

-- 2 functions:  writeLog(descr)    newLog()
-- log entry kept with timestamp 

logDepth=40   -- if too high, you might see "log or webpage too big" warnings. Suggest abt 20 max for web use or 45 otherwise

function writeLog(descr, valu)
-- note some boards seem to have occasional LONG delays on file open or file write (eg 200 msec !!!) - dangerous (watchdog timeout)
-- result is intermittent wd reset on writeLog() function.
-- solution? - maybe a replacement board with less flakey flash chip ?????

    local f = file.open("@log.var", "r")
    if not f then -- oops not existing. Create new empty one.
        newLog() 
        file.open("@log.var", "r")
    end
    file.readline() -- waste it
    local rec=file.read()..(file.read() or "") -- up to 2048
    file.close()
    if #rec>2000 or (#rec>1200 and WS_tnet) then print "Logfile too big" end -- webserver likes smaller payloads
    file.open("@log.var", "w") 
    if not valu then valu = " " end
    file.write(rec)    -- the old data less oldest line
    file.writeline("@ "..(Time and Time() or rtctime.get()) .. " -- "..descr .. " " .. valu ) -- new top line
    file.close()
end


function newLog()
    local j
    file.remove("@log.var") -- easy!
    file.open("@log.var", "w") 
    for j=1, logDepth do file.writeline("") end
    file.close() 
end

ViewLog=function() -- ideal for use in telnet - kill this if not needed
    local _line 
    local c=1
    if file.open("@log.var","r") then 
        print("--FileView start") 
        repeat 
            _line = file.readline() 
            if (_line~=nil) then 
                print(c, string.sub(_line,1,-2)) 
                c = c + 1
            end 
        until _line==nil 
        file.close() 
        print("--FileView done.") 
    else
        print("\r--FileView error: can't open file") 
    end 
end 


local rw,ex=node.bootreason()
writeLog("Reset", tostring(rw).." "..tostring(ex))  -- might want to kill this??

