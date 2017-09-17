-- lib-LOGGER.lua  

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
        f=file.open("@log.var", "r")
    end
    f:readline() -- waste it
    local rec=f:read()..(f:read() or "") -- up to 2048
    f:close()
    if #rec>2000 or (#rec>1200 and WS_tnet) then print "Logfile too big" end -- webserver likes smaller payloads
    f=file.open("@log.var", "w") 
    if not valu then valu = " " end
    f:write(rec)    -- the old data less oldest line
    f:writeline("@ "..(Time and Time() or rtctime.get()) .. " -- "..descr .. " " .. valu ) -- new top line
    f:close()
end


function newLog()
    local j
    file.remove("@log.var") -- easy!
    local f=file.open("@log.var", "w") 
    for j=1, logDepth do f:writeline("") end
    f:close() 
end

ViewLog=function() -- ideal for use in telnet - kill this if not needed
    local _line, f
    local c=1
    f=file.open("@log.var","r")
    if f then 
        print("--FileView start") 
        repeat 
            _line = f:readline() 
            if (_line~=nil) then 
                print(c, string.sub(_line,1,-2)) 
                c = c + 1
            end 
        until _line==nil 
        f:close() 
        print("--FileView done.") 
    else
        print("\r--FileView error: can't open file") 
    end 
end 


local rw,ex=node.bootreason()
writeLog("Reset", tostring(rw).." "..tostring(ex))  -- might want to kill this??

