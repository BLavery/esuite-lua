print("Project23 - analog read VDD33 + telnet")

if adc.force_init_mode(adc.INIT_VDD33) then      -- NOTE
    node.restart()  
    return 
end  
-- if adc mode was wrong mode from any earlier project, reboot correctly . Only needed once.
-- refer http://nodemcu.readthedocs.io/en/dev/en/modules/adc/#adcforce_init_mode

tmr.alarm(0, 1000, 1, 
    function()
        print(adc.readvdd33(), "mV" )               -- NOTE
    end
)

tport=23
dofile("lib-TELNET.lua")


-- setup:   nothing.


