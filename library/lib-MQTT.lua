-- lib-MQTT.lua   V 0.5
-- INCLUDE AS DESIRED IN YOUR PROJECT FILE

if not (mqtt_topics and mqtt_ready and mqtt_recv) then
    print("Error: Needed in your project: mqtt_topics={}, mqtt_ready(), mqtt_recv()")
    return
end

-- Configuration to connect to the MQTT broker.  Edit to YOUR MQTT configuration:

local BROKER = "m99.cloudmqtt.com"   -- Ip/hostname of MQTT broker
local BRPORT = 11919             -- MQTT broker port
local BRUSER = "jxxxxxxx"           -- MQTT authentication 
local BRPWD  = "Buxxxxxxxxxx"            -- The user password

local _QOS=2
local _RETAIN =  1

-- connect to the broker
local CLIENTID = "ESP-" ..  wifi.sta.getmac() -- Generates your unique MQTT ID. 
if wifi.sta.getip() == nil then print("MQTT? But no wifi!") return end

print "Connecting to MQTT broker. Please wait..."
mc = mqtt.Client( CLIENTID, 120, BRUSER, BRPWD)
mc:connect( BROKER , BRPORT, 0, 
    function(conn)
         -- connect callback
         print("Connected to MQTT:" .. BROKER .. ":" .. BRPORT)
         print(" as ClientID " .. CLIENTID )
         mqtt_sub() --run the subscription function 
    end,
    function(conn, reason)
        print("MQTT fail to connect", reason)
        --  http://nodemcu.readthedocs.io/en/dev/en/modules/mqtt/#mqttclientconnect
    end
)

function mqtt_sub()
          -- this is part of the callback when we successfully "connect" to broker
          --subscribe to the topics - MUST USE AT LEAST ONE SUBSCRIPTION
          mc:subscribe(mqtt_topics ,  function(conn)
               print("Subscribing topics: "  )
               for k in pairs(mqtt_topics) do print("",k) end
               
               -- Register the callback to receive the subscribed topic messages. 
               mc:on("message", function(conn, topic, data) mqtt_recv(topic,data) end )
               print "MQTT ready"
               mqtt_ready()     -- notify project that all is ready  
          end)
end

pub_sem = 0   
function mqtt_publish(t,d)
    if pub_sem == 0 then  -- all looks good to publish
        pub_sem = tmr.time() 
        -- MQTT Publish semaphore =nz. Stops the publishing when the previous hasn't ended (can crash esp?)
        if not mc:publish(t,d, _QOS, _RETAIN, function(conn) 
            print(string.sub(Time(), 1,5), "MQTT published ", t, d)  -- callback = async
            pub_sem = 0
        end) then 
            -- we tried to publish but it summarily failed. mqtt offline?
            print("MQTT fail")
            mc:close()
            node.task.post(function() dofile("lib-MQTT.lua") end )
        end 
    else  
        -- sem is busy. Is it too old?
        if (tmr.time() - pub_sem) > 10 then  -- too long. restart mqtt
            print("MQTT publ fail")
            mc:close()
            node.task.post(function() dofile("lib-MQTT.lua") end )
        end 
    end -- (if pub_sem)
   
end


--[[ 4 exported items:  These are handled/called at your project file
mqtt_topics = table of topic/qos pairs to be subscribed. Project sets this before MQTT library is started.
mqtt_ready() - callback from library to project when MQTT has initialised
mqtt_recv() - callback from library to project when a (subscribed) message arrives
mqtt_publish() - call from project into library to publish a payload to a topic 

--]]
