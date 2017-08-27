-- a simple telnet server
-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/telnet.lua

tport = tport or 2323
_telnet_srv = net.createServer(net.TCP, 180)
print("Telnet port: " .. (tport))
_telnet_srv:listen(tport, function(socket)
    local fifo = {}
    local fifo_drained = true

    local function sender(c)
        if #fifo > 0 then
            str=table.remove(fifo, 1)
            if #str ==0 then
                str = " "
            end
            c:send(str)
        else
            fifo_drained = true
        end
    end

    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    node.output(s_output, 1)   -- re-direct output to function s_ouput.

    socket:on("receive", function(c, l)
        node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
    end)
    socket:on("disconnection", function(c)
        node.output(nil)        -- un-regist the redirect output function, output goes to serial
        print("Telnet fin")
    end)
    socket:on("sent", sender)
    socket:on("connection", function(c)
        print("ESP8266 Telnet on")
    end )


    --print("Welcome.")
end)
