-- just PIR or button4 on pin d6 -> notify at phone
-- You MUST add the "notification" widget on APP at phone.
-- oled on sda=3 scl=4

print("Project: Blynk-PIR - notify")

pir=6  -- ie d6
gpio.mode(pir, gpio.INPUT, gpio.PULLUP)

function conn_cb()   -- calls when blynk successfully connects. Dont want trigger to work til blynk works!
        gpio.trig(pir, "down", function()
            b:send_message(blynk.commands["notify"], b:mid(), "Alarm at home")
            oled("j","Alarm " .. string.sub(Time(10),1,8))
        end)
end


function set_callbacks(b)   -- called as blynk is setting up
   b:on('connection', conn_cb)  -- set this for AFTER blynk gets connected
end


-- Load the Blynk library
dofile("{token}.lua")  -- select the token
dofile ( 'lib-BLYNK.lua' )
b = blynk.new ( token, set_callbacks ):connect()

sda = 3
scl = 4
dofile("lib-OLED.lua")
