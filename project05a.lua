print("Project05a: SONAR")
  
dofile("lib-OLED.lua")

dofile("lib-ULTRASONIC.lua")
mysonar = Sonar.new(7, 8, 4):run()  -- trig, echo, led

tmr.alarm(3, 2500, 1, function() local d = mysonar:read() print(d) end) 

-- at ESP8266 use  HC-sr04 at TRIG D6, ECHO D8 (via 6K resistor)

