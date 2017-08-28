
print("Project 07: Telnet")

tport=213
dofile("lib-TELNET.lua")
-- telnet should be now available from local PC

-- furthermore, if you execute   wifi.setmode(wifi.STATIONAP)
-- then the access point should start (usually on 192.168.4.1)
-- and you could log on by wifi to that (as a "hotspot")
-- and use telnet DIRECTLY to ESP8266, not through the local wifi router

-- eg put a telnet client on phone, and log to esp's hotspot, and run telnet.
