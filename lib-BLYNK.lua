-- BLYNK LIBRARY FOR ESP8266  V0.81 Aug17   like all libraries, best advice is "just don't touch"

-- from the blynk-esp project
-- located at https://github.com/blezek/blynk-esp
-- and a few tweaks by BL

blynk = {}
blynk.__index = blynk
blynk.commands = { register = 1, login = 2, ping = 6, notify = 14, bridge = 15, property = 19, hardware = 20, tweet = 12, email = 13  }

function blynk.dump(self,c,symb) -- function will be deleted unless "trace" defined "true" in blynk.new()
   local t, i, status_value, cmd = ''
   local f = ''
   local c1=c
   while #c1 > 1 do
       t, i, status_value = struct.unpack(">BI2I2", c1)
       f = f .. ((#f>0) and "\n" or "") .. symb .. ": " .. t .. " "  .. i .. " " .. status_value      
       if t ~= 0 and status_value > 0 then
          t, i, cmd = struct.unpack(">BI2I2c0", c1)
          c1 = string.sub(c1,#cmd+6)
          cmd = self:split(cmd)
          f = f .. " '" .. table.concat(cmd, ' ') .. "'"     
       else
          c1 = string.sub(c1, 6)  
       end  
   end
   local bytes = {}
   table.insert(bytes, string.format("0x%x", t))
   table.insert(bytes, string.format("0x%x", i))
   table.insert(bytes, string.format("0x%x", status_value))
   for i=6,#c do
      table.insert(bytes, string.format("%x", string.byte(c,i)))
   end
   print (f .. " -- " .. table.concat(bytes, ' '))
end


function blynk.new(token, setup, trace)  -- options: setup_callback, trace, 
   local self = setmetatable({}, blynk)
   self.token = token
   self.timer_id = tmr.create()
   self.message_id = 1
   self.pings = 0
   self.callbacks = {}
   self.message_queue = {}
   if setup == nil then setup = blynk_autogpio end -- if callback = nil, do autogpio
   if setup then setup(self) end -- if callback = false, omit
   if not trace then blynk.dump = nil end -- if no debug tracing, delete function
   if not self.autogpio then blynk_autogpio=nil end  -- if no auto, delete its function
   return self
end

function blynk.connect(self)     
   self.conn = net.createConnection(net.TCP, 0 )
   self.conn:on ( "receive", function (s, c)
        if self.callbacks["receive"] ~= nil then self.callbacks["receive"](s,c) end
        local t, i, status_value, cmd = ''
        --uart.write(0,"["..#c.." RX: ") for i=1,#c do uart.write(0,string.format(" %x",string.byte(c,i))) end print("]")
        if self.dump then self:dump(c, "in")  end
        local c1 = c
        while #c1>4 do  
            t, i, status_value = struct.unpack(">BI2I2", c1)
            --print ( "type: " .. t .. " id: " .. i .. " status: " .. (status_value or 'nil') ) 
            if t == 0 then 
                self.pings = 0  -- server is answering our pings
            else
                if status_value > 0 then -- ln
                   t, i, cmd = struct.unpack(">BI2I2c0", c1)
                   c1 = string.sub(c1,#cmd+1)
                   cmd = self:split(cmd)
                   local f = self.callbacks[cmd[1]]
                   if f ~= nil then 
                      f ( cmd, i )
                   end
                end
            end
            c1 = string.sub(c1,6)
        end
        
        if not tmr.state(self.timer_id) then
           tmr.register(self.timer_id, 10000, tmr.ALARM_AUTO, function()
               self:queue(self:create_message(6, self:mid(), nil),s)
               self.pings = self.pings+1
               if self.pings > 2 then self.pings = 0 wifi.sta.disconnect() end
           end)
           tmr.start(self.timer_id)
        end
   end)

   self.conn:on ( "sent", function(s)
        self:process_queue(s)
   end)
   
   self.conn:on ( "connection", function (s)
        print ( "Connected to blynk, logging in")
        self:queue( self:create_message(blynk.commands["login"], self:mid(), self.token), s)
        if self.callbacks["connection"] ~= nil then self.callbacks["connection"](s) end
   end)
   self.conn:on ( "disconnection", function (s,c)
        if tmr.state(self.timer_id) then
           tmr.stop(self.timer_id)
        end
        print ( "Disconnected from blynk", c)
        if self.callbacks["disconnection"] ~= nil then
           self.callbacks["disconnection"](c)
        end
        -- now loop waiting for net to restore ...
        wifi.sta.connect()
        tmr.start(self.timer_id, 3000, 1, function()
           if wifi.sta.getip()~=nil then
             tmr.unregister(self.timer_id)
             print("Network OK") -- so restart blynk
             node.task.post(function() b:connect()  end)
           end
        end)

   end)
   self.conn:connect(8442, "blynk-cloud.com")
   return self
end
dofile("lib-BLYNK2.lua")
