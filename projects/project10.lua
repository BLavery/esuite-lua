

dofile("lib-OLED.lua")
dofile("lib-ADC4.lua")

for c=8, 11
do
    print(c, adc.read(c) )
end
adc.write(57)

