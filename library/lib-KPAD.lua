-- library untested

local KB_KEYPADMATRIX = { { 1 , 2 , 3, "A" },           -- this 3x4 or 4x4 array defines the return values
                          { 4 , 5 , 6, "B" },           -- this layout is easy to understand
                          { 7 , 8 , 9, "C" },
                          {"*", 0 ,"#","D"}  }

KB_ROW = KB_ROW or { 13, 14, 15, 16 }  -- these are gpio pins on mcp23017 gpio expander
KB_COLUMN = KB_COLUMN or { 17, 18, 19 }      -- You COULD use 7 pins on esp8266 itself, but you won't have many left!!
local i, rowVal, colVal
local key
local timr = tmr.create()

-- multi-call scheme to allow mcp23017 slow functions not cause watchdog issues. Max task time abt 20 mSec.
local function scanKey(step)
    if step == nil then    
        step=1
        for i=1,4 do
            -- Set all 4 rows as input, pulled high
            gpio.mode(KB_ROW[i], 0, gpio.PULLUP)
        end
    elseif step==2 then 
        for i=1,#KB_COLUMN do
            -- Set all 3 columns as output 
            gpio.mode(KB_COLUMN[i], 1)
        end
    elseif step==3 then
        for i=1,#KB_COLUMN do
            -- Set all 3 columns as low
            gpio.write(KB_COLUMN[i], 0)
        end
    elseif step==4 then 
        -- Scan rows for pushed key/button
        -- A valid key press should set "rowVal"  between 1 and 4.
        rowVal = 0
        for i =1,4 do
            if gpio.read(KB_ROW[i]) == 0 then rowVal = i end
        end
        -- if rowVal is not 1 thru 4 then no button was pressed and we can exit (to SAME step)
        if rowVal <1 or rowVal >4 then tmr.alarm(timr, 10, 0,  function() scanKey(step) end ) return end
        
    elseif step==5 then
        for i=1,#KB_COLUMN do
            -- Return all columns to input, pulled high
            gpio.mode(KB_COLUMN[i], 0, gpio.PULLUP)
        end

    elseif step==6 then
        -- So, we now know there is a button pressed in that row. But which button?
        -- Switch the interesting row (found from scan) to output low

        gpio.mode(KB_ROW[rowVal], 1)
        gpio.write(KB_ROW[rowVal], 0)  
    elseif step==7 then
        -- Scan columns for still-pushed key/button
        -- A valid key press should set "colVal"  between 1 and #KB_COLUMN.
        colVal =0
        for i = 1, #KB_COLUMN do
            if gpio.read(KB_COLUMN[i]) == 0 then colVal=i end
        end
    else 
        -- Switch the that row back to input
        gpio.mode(KB_ROW[rowVal], 0, gpio.PULLUP)

        -- if colVal is not 1 thru col-count then no button was identified and we can exit & start over
        if colVal <1 or colVal >#KB_COLUMN then node.task.post(0, function() scanKey() end ) return end

        -- So, now we know both the row and the column of the button
        -- Return the value of the key pressed
        key = KB_KEYPADMATRIX[rowVal][colVal]  
        tmr.alarm(timr, 400,0, function() scanKey() end ) 
        return
    end
    node.task.post(0, function() scanKey(step+1) end )  -- to next step
end

scanKey()  -- start your engines

function getKey()  -- call from your project to get keystroke
    local k = key
    key = nil
    return k
end
