-- project06.lua

print("Project06: 'SMART' Flash button")
 
dofile("{token}.lua")
dofile ( 'lib-BLYNK.lua' )
b=blynk.new (token):connect()

b0 = function() -- short press
    print ("b0 pressed") 
    b:send_message(blynk.commands["hardware"], b:mid(), b:pack('vw', "0", "All OK") ) -- set widget text
    b:send_message(blynk.commands["property"], b:mid(), b:pack('0', 'color', "#00ff00") )  -- set widget color green
end
b1 = function() -- 1 sec press
    print ("b1 pressed") 
    b:send_message(blynk.commands["hardware"], b:mid(), b:pack('vw', "0", "Risky") )
    b:send_message(blynk.commands["property"], b:mid(), b:pack('0', 'color', "#FFaD00") )  -- yellow
end
b3 = function() -- 3 sec press
    print ("b3 pressed") 
    b:send_message(blynk.commands["hardware"], b:mid(), b:pack('vw', "0", "Hi Alert") )
    b:send_message(blynk.commands["property"], b:mid(), b:pack('0', 'color', "#FF0000") )  --red
end

dofile("lib-SMARTBTN.lua")
smartButton(3, b0, b1, b3)

-- on phone, use widget "Value Display" Virtual Pin 0, PUSH (ie not polling)
-- colours are standard html #RRGGBB style. Google "html color".
--    Or see http://docs.blynk.cc/#blynk-main-operations-change-widget-properties


