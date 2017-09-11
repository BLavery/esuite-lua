-- https://captain-slow.dk/2015/04/16/posting-to-thingspeak-with-esp8266-and-nodemcu/



APIKEY=APIKEY or "-- need your thingspeak write apikey --"
print("ThingSpeak Init" .. APIKEY)

if not rtcmem then 
    print("Needs rtcmem in build")
    return
end

-- simplistic: just 1 field of data per call!  But it works!
function postThingSpeak(fieldnumber, data, fieldname)
    field = "field" .. tostring(fieldnumber)
    fieldname = fieldname or field
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print(string.sub(Time(), 1,5).." Posted "..fieldname.." = "..tostring(data).." to Thingspeak");
        end
        if (string.find(payloadout, "Status: 400 Bad") ~= nil) then
            print("Thingspeak Fail");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
        connout:send("GET /update?api_key="..APIKEY.."&"..field.."=" .. tostring(data)
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout = nil
        collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')
end

-- if you post more often than 15 secs between posts, thingspeak may return "OK", 
-- but silently the entry will not be recorded!
