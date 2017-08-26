-- optional wifi connection monitor
-- prints messages when wifi fails or gets restored

-- note wifi reconnection is normally an automatic & silent process. This lib prints advice.

wifidiscon = 0
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED , function(T)   
        node.task.post(function () print("Wifi connect: ", T.SSID)  end ) 
        wifidiscon = 0
    end )

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP , function(T)   
    node.task.post(function () print(T.IP)  end ) end )


wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED , function(T) 
        if wifidiscon ~= T.reason then   
            node.task.post(function () print("Wifi disconnect: ", T.SSID, T.reason)  end ) 
            wifidiscon = T.reason
        end
    end )

-- the magic codes?
--  http://nodemcu.readthedocs.io/en/dev/en/modules/wifi/#wifieventmon-module
