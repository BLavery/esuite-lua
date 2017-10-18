-- Derived from MAX7219 module: marcel at https://github.com/marcelstoer/nodemcu-max7219

-- uses pins D5=clk(8266)=clk(Max7219)  D7=mosi(8266)=DataIn(Max7219) D8=cs(8266)=cs(Max7219)   VCC to +5

-- several options may be made in your project before loading max7219 library:
-- defaults to 7seg module support. "MAX_type=8" to use 8x8 modules instead.
-- Supports daisychained MAX7219 devices. "MAX_modules=4" to configure for (example) 4 modules. Def 1.
-- slave select (CS) on D8 may be customised with "MAX_cs=x" for pin Dx
-- LED intensity configurable 0-15 default 1. "MAX_intensity=6"

-- Comment: this code is "hacked" from marcelstoer code,
-- but it is poorly done, and deserves a careful overhaul.
-- However, for its job, it does work ... and so ... <g>
 
max7219={}

local numberOfColumns
-- ESP8266 pin which is connected to CS of the MAX7219

-- MAX_modules * 8 bytes for the char representation, left-to-right
local columns = {}

local MAX7219_REG_DECODEMODE = 0x09
local MAX7219_REG_INTENSITY = 0x0A
local MAX7219_REG_SCANLIMIT = 0x0B
local MAX7219_REG_SHUTDOWN = 0x0C
local MAX7219_REG_DISPLAYTEST = 0x0F

local function sendByte(module, register, data)
  local spiRegister = {}
  local spiData = {}
  local i

  -- set all to 0 by default
  for i = 1, MAX_modules do
    spiRegister[i] = 0
    spiData[i] = 0
  end

  -- set the values for just the affected display
  spiRegister[module] = register
  spiData[module] = data

  -- enble sending data
  gpio.write(MAX_cs, gpio.LOW)
  
  if MAX_type ==8 then
      for i = MAX_modules, 1, -1 do
        if not spiData[i] then spiData[i] = 0 end
        spi.send(1, spiRegister[i] * 256 + spiData[i])
      end
  else
      for i = 1, MAX_modules do
        if not spiData[i] then spiData[i] = 0 end
        spi.send(1, spiRegister[i] * 256 + spiData[i])
      end
  end

  -- make the chip latch data into the registers
  gpio.write(MAX_cs, gpio.HIGH)
end

local function numberToTable(number, base, minLen)
  local t = {}
  repeat
    local remainder = number % base
    table.insert(t, 1, remainder)
    number = (number - remainder) / base
  until number == 0
  if #t < minLen then
    for i = 1, minLen - #t do table.insert(t, 1, 0) end
  end
  return t
end


local function commit()
  local i
  for i = 1, numberOfColumns do
    local module = math.floor(((i - 1) / 8) + 1)
    local register = math.floor(((i - 1) % 8) + 1)
    sendByte(module, register, columns[i])
  end
end


MAX_modules = MAX_modules or 1
MAX_cs =MAX_cs or 8
numberOfColumns = MAX_modules * 8

print("MAX7219: type: " .. ((MAX_type == 8) and "8x8" or "7Seg") .. ", modules: " .. MAX_modules .. 
      ", cs pin: " .. MAX_cs )
spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 16, 8)
-- Must NOT be done _before_ spi.setup() because that function configures all HSPI* pins for SPI. Hence,
-- if you want to use one of the HSPI* pins for slave select spi.setup() would overwrite that.
gpio.mode(MAX_cs, gpio.OUTPUT)
gpio.write(MAX_cs, gpio.HIGH)
local i
for i = 1, MAX_modules do
    sendByte(i, MAX7219_REG_SCANLIMIT, 7)
    sendByte(i, MAX7219_REG_DECODEMODE, 0x00)
    sendByte(i, MAX7219_REG_DISPLAYTEST, 0)
    -- use 1 as default intensity if not configured
    sendByte(i, MAX7219_REG_INTENSITY, MAX_intensity and MAX_intensity or 1)
    sendByte(i, MAX7219_REG_SHUTDOWN, 1)
end


function max7219.clear()
  for i = 1, numberOfColumns do
    columns[i] = 0
  end
  commit()
end


-- display: true=turn off, false=turn on
function max7219.shutdown(shutdown)
  for i = 1, MAX_modules do
    sendByte(i, MAX7219_REG_SHUTDOWN, shutdown and 0 or 1)
  end
end

-- RAW _write() mode:
function max7219._write(chars) -- chars is table of 1 or more char8's

  local c = {}
  local i
  for i = 1, #chars do
    local char8 = chars[i]  -- char8 is 8 bytes, for one 7seg or one 8x8 device
    local k,v
    for k, v in ipairs(char8) do
        table.insert(c, v)
    end
  end
  columns = c
  commit()
end

-- load only one of the two write() options:
if MAX_type==8 then -- 8x8 mode
    if not file.exists("|char8x8") then  
        node.task.post( 2, function() dofile("x-font8x8.lua") node.restart() end) 
    else 
        _initw = true -- without this flag, max7219.write() is inhibited. One restart & all should be fixed!
    end

    function max7219.write(text)
        if not _initw then return end  -- temporarily, ignore led writes until font file is first created
        local i, j, currentChar, tab
        local c = {}
        if text =="" then text = " " end
        file.open("|char8x8", "r") 
        for i = 1, #text do
            currentChar = text:sub(i,i)  
            x=file.seek("set",8*string.byte(currentChar))  
            c8 = file.read(8) 
            tab = {}
            for j = 8, 1, -1 do
                table.insert(tab, string.byte(c8:sub(j,j)))
            end 
            table.insert(c, tab)     
        end
        file.close()
        max7219._write(c)    
    end

else  -- 7 seg mode

    if not file.exists("|char7seg") then  
        node.task.post( 2, function() dofile("x-font7seg.lua") node.restart() end) 
    else 
        _initw = true
    end

    -- Writes the specified text to the 7-Segment display.
    -- If rAlign is true, the text is written right-aligned on the display.
    function max7219.write(text, rAlign)
      if not _initw then return end  -- temporarily, ignore led writes until font file is first created
      local tab = {}
      if text =="" then text = " " end
      local lenNoDots = text:gsub("%.", ""):len()
      file.open("|char7seg", "r") 
      
      -- pad with spaces to turn off not required digits
      if (lenNoDots < (8 * MAX_modules)) then
        if (rAlign) then
          text = string.rep(" ", (8 * MAX_modules) - lenNoDots) .. text
        else
          text = text .. string.rep(" ", (8 * MAX_modules) - lenNoDots)
        end
      end

      local wasdot = false

      for i = string.len(text), 1, -1 do
        local currentChar = text:sub(i,i)
        file.seek("set",string.byte(currentChar)-1)
        local c7 = string.byte( file.read(1))   
        if (currentChar == ".") then
          wasdot = true
        else
          if (wasdot) then
            wasdot = false
            -- take care of the decimal point
            table.insert(tab, c7 + 0x80)
          else
            table.insert(tab, c7)
          end
        end
      end
      file.close()
      max7219._write({ tab })
    end
    
end

max7219.clear()
MAX_intensity=nil
MAX_type=nil

-- active cs is compulsory ! can't just strap lo.


