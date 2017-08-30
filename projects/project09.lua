print("Project09 - extended GPIO & ADC pins")
-- This demo uses BOTH mcp23017 and cd4051
-- to give digital GPIO up to "D28" and analog up to "A7"
-- (exc 3 gpios 21-23 were stolen for addressing the analog multiplexer)

dofile("lib-OLED.lua")
dofile("lib-GPIO28.lua")

gpio.mode(15,1)   -- ie GPA2 on 23017
gpio.write(15,math.floor(node.random()*2 % 2))  -- random HI or LO to D15

dofile("lib-ADC8.lua")
adc.init8(21)
for c=0, 7
do
    print(c, adc.read(c) )  -- A5 should show random 0 or 1024 each reset
end

-- SETUP:  
--    MCP23017 strapped as i2c address 0x20 (VDD=RST*=+3.3, VSS=gnd, SCL-D1, SDA-D2, A0=A1=A2=gnd)
--    CD4051 Anl-Common=ESP-A0, E*=VEE=GND=gnd, VCC=+3.3
--    ... and 3 addresses of Anl (S0 S1 S2) driven by MCP23017 GPB0-GPB2 (our D21-D23)
--    ... and strap GPA2 (our D15) into A5 analog input. We can toggle digital out & see it on analog input.
-- Total 5 wires to ESP8266: D1 (ie SCL) D2 (ie SDA) +3.3 Gnd and A0
