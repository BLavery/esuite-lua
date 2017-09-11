print("Project 21: Thingspeak DHT22")

-- logging weather station
-- DHT22 on pin D6
-- ESP publishes Temp & Humidity every 20 mins to thingspeak

dofile("lib-OLED.lua")

DHT = 6

dofile("lib-THINGSPEAK.lua")

_MINS=60000
_SECS=1000
temp=0
humidity=0
function readWeather()
    stat, temp, humidity = dht.read(DHT)
end
readWeather()
-- a 60-second time displays on terminal
tmr.alarm(0, 1*_MINS, 1, function()
    readWeather()
    print(string.sub(Time(), 1,5), temp, humidity, adc.read(0))
end)

ctr=0
tmr.alarm(2, 10*_MINS, 1, function() -- 20 minutes cycle - 2 x 10 mins
    -- stagger 2 readings: our simple publish function needs time to process (ie couple of seconds??? <g>)
    ctr = (ctr+1) % 2
    if ctr == 0 then
       postThingSpeak(1, temp, "Temperature") 
    else
       postThingSpeak(2, humidity, "Humidity") 
    end 
    oled("m", {string.sub(Time(), 1, 5), tostring(temp), tostring(humidity), ""})
end )

-- dofile("lib-TELNET.lua")  -- optional
