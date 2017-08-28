-- a general template for BLYNK and automated/generic GPIO I/O

-- LUA uses the "Dx" label numbering for GPIOs, not the real CPU GPIO numbers. (ie unlike arduino mode)

-- gpio setup - 4-button set plus RGB LED: What GPIOs are they on (in Dx numbering)

--Red=2
--Blue=1
--Green=0

--but1=7
--but2=8
--but3=5
--but4=6

--flashButton=3
--pcbLED=4

-- i2c OLED on sda 3 scl 4

-- PRE-CONFIGURE ALL GPIOs:   http://nodemcu.readthedocs.io/en/dev/en/modules/gpio/#gpiomode
gpio.mode(5, gpio.INPUT, gpio.PULLUP) -- 4 buttons input+pullup
gpio.mode(6, gpio.INPUT, gpio.PULLUP)
gpio.mode(7, gpio.INPUT, gpio.PULLUP)
gpio.mode(8, gpio.INPUT, gpio.PULLUP)
gpio.mode(3, gpio.INPUT)    -- pcb button input - has its own pullup

--[[
-- configure outputs if need hi/lo to be correct from start, before phone sends first commands
gpio.mode (0, gpio.OUTPUT)  -- 3 RGB leds as outputs, LOW
gpio.write(0, gpio.LOW)
gpio.mode (1, gpio.OUTPUT)
gpio.write(1, gpio.LOW)
gpio.mode (2, gpio.OUTPUT)
gpio.write(2, gpio.LOW)
gpio.mode (4, gpio.OUTPUT)   -- PCB LED as output, HIGH (=off)
gpio.write(4, gpio.HIGH)
--]]


-- Load the Blynk library and run in auto-gpio mode
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
blynk.new (token):connect()
sda=3 scl=4
dofile("lib-OLED.lua")

