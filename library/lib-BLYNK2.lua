-- part2
function blynk.queue(self,message,s)
   table.insert(self.message_queue, message)
   self:process_queue(s)
end

function blynk.process_queue(self, s)
   if s == nil then
      s = self.conn
   end
   if #self.message_queue > 0 and s:getaddr() then -- occasional net fail appears here before "disconnect"
      s:send(table.remove(self.message_queue,1))
   end
end


function blynk.disconnect(self) -- unsafe to call, tmr alive
   self.conn:close()
   return self
end

function blynk.split(self,cmd)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( cmd, '\0', from  )
  while delim_from do
    table.insert( result, string.sub( cmd, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( cmd, '\0', from  )
  end
  table.insert( result, string.sub( cmd, from  ) )
  return result
end

function blynk.pack (self,...)
   return table.concat(arg, string.char(0))
end

function blynk.on(self, message, func)
   self.callbacks[message] = func    
   return self
end

function blynk.mid(self)
   self.message_id = self.message_id+1
   return self.message_id
end

-- create and send
function blynk.send_message ( self, cmd, mid, payload )
   self:queue(self:create_message(cmd,mid,payload))
end

-- a blynk message is 8bit type, 16bit mid, 16bit length, payload and '\0'
function blynk.create_message ( self, cmd, mid, payload )
   local msg
   if payload ~= nil then
      --print ( "message is: " .. cmd .. " " .. mid .. " " .. string.len(payload) .. ' ' .. payload)
      msg = struct.pack ( ">BI2I2c0", cmd, mid, string.len(payload), payload)
   else
      --print ( "message is: " .. cmd .. " " .. mid )
      msg = struct.pack ( ">BI2I2", cmd, mid, 0)
   end

   if self.dump then  self:dump(msg,"out") end
   return msg
end

function blynk.write(self, pintype, vpin, payload) -- pintype "vw" or "dw"
    self:send_message(self.commands["hardware"], self:mid(), self:pack(pintype, tostring(vpin), tostring(payload)))
end

-- following function is for common generic (automated) dw and dr and adc0 GPIO action. 
-- Will be nil'd if not used (abt 1kB)
-- Usage:    b = blynk.new ( token )   The nil callback installs autogpio
-- alternatively, use regular setup_callback(b) as in b = blynk.new ( token, setup_cb)
--      and inside the callback manually call "blynk_autogpio(b)" 
-- autogpio still needs user project to preconfigure gpio modes:

-- some gpio.mode() notes:
-- the gpio.write() in auto-gpio function will usually CAUSE that gpio to go to output mode.
-- the onboard led on D4 is an exception. Your project MUST explicitly set that to output if you want to use it.
-- the gpio.read() in auto-gpio function will always read pin value, and most pins start INPUT by default.
-- however, it's best to explicitly set your inputs in your project, and especially those needing pullup.

function blynk_autogpio(b) 
   -- all digital writes & digital reads to be handled automatically. No special code per each.
   b:on ('dw', function (cmd)  
         gpio.write(cmd[2],cmd[3]) -- and will implicitly set mode to output
   end)  
   b:on ('dr', function (cmd, orig_msgid) 
         b:send_message(blynk.commands["hardware"], orig_msgid, b:pack('dw', cmd[2], tostring(gpio.read(cmd[2]))))
   end) 
   b:on ('ar', function (cmd, orig_msgid) -- adc0 only. Caution: user may need check "force_init_mode" first.
         b:send_message(blynk.commands["hardware"], orig_msgid, b:pack('aw', cmd[2], tostring(adc.read(0))))
   end) 
   b:on ('pm', function (cmd) 
       uart.write(0, "Gpio req: ") for i=2, #cmd, 2 do uart.write(0, cmd[i]..cmd[i+1].." ") end print("") 
       -- Only a report. Project file needs to make these mode settings
   end) 
   b.autogpio=true
end

