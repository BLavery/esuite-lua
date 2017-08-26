# eSuite

An integrated collection of Lua files for ESP8266

The manual



Overview:

This suite of files is intended primarily for use with ESP12-based boards (including NodeMCU and Wemos D1-mini), but it does work for ESP-01, within its gpio limits.

It automates the startup including escape time, wifi connection and time setting. This leaves your project scripting to concentrate on exactly what you want to control. Included is a collection of drop-in library files for many common devices. The library files are generally fairly practical and needing minimal configuration in your project.

The eSuite projects are intended to be used as client (&quot;STATION&quot; mode) in conjunction with a nearby wifi access point. The ESP8266 is a wifi-capable chip, and merely using an isolated &quot;blink a LED&quot; project misses its point!

The NodeMCU build from   **http://nodemcu-build.com** will need to include code modules required for your project. I typically build with these options, and use the &quot;float&quot; version:

adc, adxl345, bit, bme280, dht, file, gpio, http, i2c, mqtt, net, node, pwm, rtcmem, rtctime, sntp, spi, struct, tmr, u8g, uart, wifi. U8g supports the OLED screens, so choose 128x64 or 64x48 according to your type.  Use a NEW build of firmware. Some commands changed syntax in 2017.  Recommend using **pyFlasher** to load to ESP.  See https://github.com/marcelstoer/nodemcu-pyflasher.

ESPlorer is assumed as the regular IDE used for loading lua scripts to the ESP8288 and for interacting with your project during testing.



Common startup files:

- .init.lua
- .init2-WIFI.lua
- .init3-TIME.lua

These are always used. They chain in sequence, and then pass control to your individual &quot;project&quot; file.



Library Files:

- .lib-BLYNK.lua
- .lib-LOGGER.lua
- .lib-OLED.lua
- .lib-OLED-D1.lua
- .lib-SERVO.lua
- .lib-DEEPSLEEP.lua
- .lib-MQTT.lua
- .lib-ACCEL.lua
- .lib-TELNET.lua
- .lib-THINGSPEAK.lua
- .lib-ULTRASONIC.lua
- .lib-WEBSERV.lua
- .lib-WIFIMON.lua
- .lib-SMARTBTN.lua
- .lib-GPIO25.lua
- .lib-ADC8.lua

You **optionally** include library files into your project file.



init.lua:

Has a 5 second wait period before chaining to WIFI file. During the wait time the inbuilt led (D4) on ESP12 submodule will blink. The &quot;flash&quot; button (D3) is read at the END of the blinking period, and if being held will abort any further processing. This allows a crashing lua file to be caught before entering reboot cycle.

The 5 second wait time uses timer 0. With ESPlorer, using COMMANDS tab / TIMER STOP 0  will also prevent further processing. Then you can remove/repair any misbehaving lua scripts.

The top line declares the project file you are running.  Eg    proj = &quot;project12&quot;: that would run project12.lua.

Init.lua includes an intercept to recognise a wake out of deepsleep, and optionally to start up differently. This functionality is discussed in deepsleep module.

Init.lua permits the ESP to auto-connect (while waiting during blinking mode) to last saved wifi access point. In any case, the file init2-WIFI is called after the wait time.

init2-WIFI.lua:

If the ESP has successfully auto-connected, this file has nothing to do, and chains immediately to init2-TIME. Otherwise it waits and continues retrying to connect, if necessary cycling between the configured wifi credentials given.

One or several wifi stations may be listed as acceptable. This allows for easily using in classroom and at home: the ESP will find the available Access Point for each premises.

A single AP can be designated like this:

APlist = { &quot;ap&quot;, &quot;pw&quot; }



Multiple can be listed like this:

APlist = {

**   **  **{&quot;JohnsHome&quot;, &quot;xxxxxx&quot;},**

**   **  **{&quot;theSands&quot;, &quot;password&quot;},**

**   **  **{&quot;bluerat&quot;, &quot;yyyyyyyy&quot;}**

}

After wifi becomes connected in this process, then if any later disconnect occurs, the ESP will automatically reconnect to that same AP when available.

On wifi connection, control is passed to init3-TIME.

As currently programmed, this module does NOT PROGRESS FURTHER if no wifi connection is established.

Note that is IS LEGAL (if unusual) to call init2-WIFI again later from your project. init2-WIFI in this case will not chain to SNTP or other files. It will allow you to attemt connections to the other Acess Points in your list.



init3-TIME.lua:

This module connects on the internet to a SNTP server to set the realtime clock of the ESP.  As currently programmed, one of **1.au.pool.ntp.org** up to **4.au.pool.ntp.org** is randomly chosen. You may choose to use other time servers to suit your location. Note that frequently calling a single timeserver (eg during rapid testing/rebooting) seems sometimes to cause denials from the afflicted timeserver!

Fetching true time can sometimes fail, in which case ESP time is usually set at 1970.  If time from SNTP server fails, **and** the ESP is awaking from deepsleep, then the time is left at the time preserved by the deepsleep functioning. This can be a bit inaccurate, as the low-res timekeeping during deepsleep may run fast or slow by as much as (from experience) 5%.

On either success or fail, control passes to your project file.

This file leaves a Time(ts) function for converting any system timestamp into readable text. Without any parameter, it returns current time.

Note that is IS LEGAL (if unusual) to call init3-TIME again later from your project. init3-TIME in this case will not chain recursively to your project file (which is still running)..  But it will attempt again to fetch true time.



Your Project File:

The project file is named at top of init.lua. The ESP filesystem may have multiple project files loaded at any time. Change init.lua to run a different project.

When your project file starts,

1. Wifi connection has been established
2. Best effort has been made to set real-time in the ESP&#39;s clock.

The init sequence (init.lua, init2-WIFI.lua, init3-TIME.lua) are considered as (approximately) fixed unchanging files. Every project uses them as the startup sequence.  All your individual project scripting belongs in your project file, which in many cases can be quite brief.  For example (jumping ahead to the blynk library!) the following 2-line **complete** project file can use BLYNK app on your phone to control the GPIO inputs and outputs on the ESP:

--  myproject.lua

dofile ( &#39;lib-BLYNK.lua&#39; )

blynk.new (&quot;your ...... blynk token&quot;):connect()

Even simpler, try this one-line project file!

dofile(&quot;lib-TELNET.lua&quot;)



**lib-OLED.lua** (and lib-OLED-D1.lua):

This library is for the common &quot;0.96-inch&quot; 128x64 I2C oled display. By default it uses SDA=D2 and SCL=D1 for I2C. These can be overridden.  Load the library in your project file like this, omitting the SDA and SCL lines if default pins are OK::

sda = 3

scl = 4

dofile(&quot;lib-OLED.lua&quot;)

On initialising, the current node&#39;s wifi hostname and IP number and the time will display.

There are four standard calls your project can make to display on the OLED:

- .Journal mode:
stack of up to four log messages, pushed in one at a time at the bottom

oled(&quot;j&quot;, &quot;new entry&quot; )

- .MessageBox mode:
Bold header text, with three message lines in a box

oled(&quot;m&quot;, { &quot;WARNING !&quot;, &quot;&quot;, &quot;IP Address &quot;, wifi.sta.getip() } )

- .Yell mode:
Two very bold words

oled(&quot;y&quot;, { &quot;STOP&quot;, &quot;WRONG WAY&quot; } )

- .Value Bar mode:
Scaled display bar 0-100

oled(&quot;b&quot;, { &quot;Temp&quot;, 17} )

If the oled failed to initialise, oled() calls still in your project code are harmless.  If your binary lua build did not include the correct u8g modules, initialising may crash!

lib-OLED-D1 is a rescaled version suited to smaller OLED used by D1 Mini OLED shield.

Oled library is simply based on U8G examples in NodeMCU project.



lib-BLYNK.lua:

This library (a derivative of Blezek library) connects to the BLYNK APP on your android or apple phone or tablet. Blynk includes many &quot;widget&quot; icons to control or read devices or GPIOs on the target &quot;device&quot;. Our device (aka our &quot;hardware&quot;) is the ESP8266.  You will configure a widget on the APP for each thing you want to control on the ESP.

But you must configure the &quot;device&quot; setting on your tablet as &quot; **generic**&quot;, not &quot;ESP8266&quot; or &quot;NodeMCU&quot;. Both those will attempt to use native CPU gpio numbers at your ESP. That would suit &quot;arduino mode&quot; of programming the ESP8288, but our eSuite is written in Lua which uses the &quot;D0 D1&quot; labelling as written on the module.

The library has TWO files, lib-BLYNK.lua and lib-BLYNK2.lua. They come as a pair. As lua files go, this is a large library. Loading a single file this size has a high risk of a memory crash. (You will see &quot;E:M&quot; messages and panic reboot.) The file splitting reduces the memory stress. You do not reference the second file: it is loaded automatically by the first.

Using Blynk library can be trivially easy, as above, or it may require some careful scripting to customise it to exactly what you want.

The full initialising in your project is like this:

dofile ( &#39;lib-BLYNK.lua&#39; )

b=blynk.new (&quot;your ...... blynk token&quot;, setup\_callback\_function, TraceMode)

b:connect()

The bottom lines can be merged as in the example earlier.

**TraceMode** may be omitted. If it is true then a diagnostic trace of each data packet to and from the blynk server is displayed.

If the **setup\_callback\_function** is **omitted or nil** , then a generic GPIO I/O functioning is automatically provided for gpio.read() and gpio.write(). Setup\_callback may also be set as **false** , in which case no callback is made. If you DO specify your own callback, it will happen immediately the blynk &quot;object&quot; is created, and you would use it to &quot;register&quot; more callbacks for later.  Study the following project file. (Approximately) study it from bottom up.

**function dw\_cb(cmd)**  -- gpio write

**   ** **gpio.write(cmd[2],cmd[3])**

end

**function dr\_cb(cmd, msgid)  **  -- gpio poll

**   ** **value =  tostring(1 - gpio.read(cmd[2]))**

**   ** **b:send\_message(blynk.commands[&quot;hardware&quot;],**

**                         ** **msgid, b:pack(&#39;dw&#39;, cmd[2], value))**

end

**function pm\_cb(cmd)  ** -- let us do auto setup of gpios to match the APP

**   **  **for i=2, #cmd, 2 do**

**       ** **if cmd[i+1] == &#39;in&#39; then**

**             ** **gpio.mode(cmd[i], gpio.INPUT, gpio.PULLUP)**

**       **** end  **

**       ** **if cmd[i+1] == &#39;out&#39; then**

**             ** **gpio.mode(cmd[i], gpio.OUTPUT)**

**             ** **gpio.write(cmd[i],0)**

**       **  **end**

**   **  **end**

end

function set\_callbacks(b)

**   **** b:on (&#39;dw&#39;, dw\_cb) ** -- means:** on** occurrence if any &quot;dw&quot; event, call dw\_cb()

**   **** b:on (&#39;dr&#39;, dr\_cb)**

**   **** b:on (&#39;pm&#39;, pm\_cb)**

end

dofile ( &#39;lib-BLYNK.lua&#39; )

b = blynk.new ( token, set\_callbacks ):connect()

At the bottom, we start blynk, and that triggers the &quot;set\_callbacks&quot; function. set\_callbacks() registers three further callbacks that blynk will later call at each &quot; **pm**&quot; message or &quot; **dw**&quot; or &quot; **dr**&quot; message.

Blynk keeps an array of callbacks, including

- .&quot;receive&quot;, &quot;connection&quot;, &quot;disconnection&quot; (all events happening at the level of TCP/IP connection to blynk server, and that we usually don&#39;t want to know about), and
- .optionally any of the blynk incoming message designators, &quot;pm&quot;, &quot;dr&quot;, &quot;dw&quot;, vr&quot;, &#39;vw&quot; and &quot;ar&quot; (ie digital read, virtual write etc). These are as viewed from the APP&#39;s perspective, so &quot;dw&quot; is a write from APP, expecting us to change a GPIO pin..

The example we are examining will use the &quot;dr&quot; and &quot;dw&quot; for gpio control, and &quot;pm&quot; which advises of the APP widget expectations.

Blynk calls back on events like &quot;dw&quot;, &quot;dr&quot; etc (the data packets coming from the server, ie from your phone) only if you &quot;register&quot; to receive for those events with the **b:on()** command.

These callbacks receive as payload the parameter &quot;cmd&quot;. cmd is an array (table) like

{ &quot;dw&quot; , &quot;4&quot;, &quot;0&quot; } , where we already knew the &quot;dw&quot;, the next is pin number, the third is (in this case) the 1 or 0 (High/Low) for the write. So getting pin number is as easy as cmd[2].

It can be important to recognise that all the indexed members of the cmd table are STRINGS. It is wise to immediately force the parameters you are expecting as numeric to really be numeric like this:   **pin = tonumber(cmd[2]).  **Otherwise you may find errors in your code where the string value was not acceptable, a number being needed.

So now we have set blynk to call back on every incoming &quot;pm&quot;, &quot;dr&quot; and &quot;dw&quot;. pm\_cb() lets us configure our GPIOs according to the current APP widgets.  dw\_cb() happens each digital write message, so we simply perform the requested write to the real hardware.  And at each &quot;dr&quot; we read the hardware and invert the 0 / 1 (because we know it&#39;s a pull-to-ground button where 0 = PRESSED). Then we do a b:send\_message() to push the reading back to the APP, typically in a &quot;Value Display&quot; widget set to scheduled polling mode.  And this time the &quot;dw&quot; label refers to the viewpoint of our ESP, ie &quot;dw&quot; is outgoing, towards the APP.



- - - - - - -

Let&#39;s look at another example project file:

**pir=6**  -- ie d6

gpio.mode(pir, gpio.INPUT, gpio.PULLUP)

**function conn\_cb()**   -- calls when blynk successfully connects.

**       ** **gpio.trig(pir, &quot;down&quot;, function()**

**           ** **b:send\_message(blynk.commands[&quot;notify&quot;], b:mid(), &quot;Alarm at home&quot;)**

**       ** **end)**

end

**function set\_callbacks(b)**   -- called as blynk is setting up

**   **** b:on(&#39;connection&#39;, conn\_cb)  **-- set this for AFTER blynk gets connected

end

dofile ( &#39;lib-BLYNK.lua&#39; )

b = blynk.new (&quot;the token&quot;, set\_callbacks ):connect()

At the top, we assign a PIR sensor on D6 as input. We will shortly further assign it as &quot;TRIG&quot; operation, ie to cause its own callback action if it senses an intruder.

At bottom, we start blynk with set\_callbacks function. That function (a few lines earlier) &quot;gets called&quot; and it is given the blynk object (b) as its payload, in case it didn&#39;t know it.  Its job is to instruct b that when b (ie blynk) establishes server connection then call another callback we called conn\_cb.  OK, so a very short time later (half second??) blynk gets connected, and calls conn\_cb(). Conn\_cb puts D6 into trigger mode, and tells D6 to call that &quot;b:send\_message()&quot; to our APP on any alarm.   Callback within callback within callback.  Oh, and an anonymous function as well. There was a lot in that 12 line project file!

**Result:** Each intruder event sends a notification to your phone.

- - - - - - -



The last function in lib-BLYNK file is blynk\_autogpio(). You can study that to see that it follows the same patterns as the hand-coded examples above.

It is also legal to specify your own setup\_callback in the blynk.new() line, so that the autogpio is NOT the automated callback now, ... **and then** to include your own call to blynk\_autogpio(b) inside YOUR setup\_callback.  That way, you can get the automated GPIO handling, and still have opportunity to do any further setup you need.

- - - - - - -

The **send\_message()** syntax in blynk is a bit arcane, sorry.  Here are some other templates:

**b:mid()** -- generates our new (sequential) message ID number for outgoing message.

When your outgoing message is a REPLY to incoming poll/request, you should use instead the original message ID that just came in. (Although it does not seem to matter a lot?)

function vw\_cb(cmd)

    -- whatever you want. Note some vw (eg from accelerometer in phone)

    -- might have several cmd[] parameters

end

function vr\_cb(cmd, orig\_msgid)

    -- prepare your payload value to be sent back to APP

**   ** **b:send\_message(blynk.commands[&quot;hardware&quot;], orig\_msgid,**

**                           **** b:pack(&#39;vw&#39;, cmd[2], str\_payload))**

    -- For virtual pins, several payload parameters might be legitimate in some cases

end

b:send\_message(blynk.commands[&quot;hardware&quot;], b:mid(),

**                             ** **b:pack(&#39;vw&#39;, vpin, str\_payload))**

Case of &quot;vw&quot; being pushed from ESP to APP, but not in response to any poll from APP. We need our own new message id.

b:send\_message(blynk.commands[&quot;bridge&quot;], b:mid(),

**                             ** **b:pack(&#39;20&#39;, &#39;i&#39;, remote\_token ))**

Create bridge ESP to ESP. This message is addressed to our server. Register the other ESP&#39;s token against our VP 20.

b:send\_message(blynk.commands[&quot;bridge&quot;], b:mid(),

**                             ** **b:pack(&#39;20&#39;, &#39;vw&#39;, &#39;65&#39;, str\_payload))**

Bridge message from ESP to ESP. This message leaves here as writing to our Virtual Pin 20, but the server already knows that that pin is a bridge to another ESP. In this example, the server sends message { &quot;vw&quot;,  &quot;65&quot;,  &quot;payload&quot; } to the other ESP, who doesn&#39;t care quite where the message originated from!

**b:send\_message(****blynk.commands[&quot;property&quot;]****, b:mid(),**

**                             ** **b:pack(vpin, &#39;color&#39;, &quot;#123456&quot;))**

This changes widget colour (std html colour codes). ONLY for virtual pin, not digital pin.

There is one helper function provided for the &quot;vw&quot; and &quot;dw&quot; writes to the APP. Eg

b:write(&quot;vw&quot;, 5, value)

This just simplifies the longhand hardware/vw or /dw send\_message() as above. These two commands are the most common customised requirement, so this simpler version is welcome!

- - - - - - -

The commands &quot;hardware&quot;, &quot;property&quot;, &quot;bridge&quot; and &quot;notify&quot; seen above are blynk terms. You can see them at top lines of library.

Under various communication/network problems, or loss of server response, blynk can disconnect. It will attempt to restore connection and log in again to the server when it becomes possible.  If wifi itself fails, then of course blynk is disconnected. Wifi should auto-reconnect when/if available, and then blynk should also log itself in again.

Blynk library is derived from https://github.com/blezek/blynk-esp, Daniel Blezek, MIT licence, 2016. That website has some usage information that may be useful for this variant of the library.



lib-ULTRASONIC.lua:



This module is for HC-SR04 &quot;sonar&quot; 4-pin device. This is a 5 volt item, and will not work satisfactorily at a 3.3V supply. The easiest interface to ESP8266 is:

- .to feed its VCC pin from 5V on the NodeMCU,
- .to simply presume that a 3.3V trigger from ESP8266 will suffice for the 5V sonar (outside spec, but it usually works fine),
- .and to connect the echo pin VIA A 6K RESISTOR specifically to D8 (gpio15). That pin on ESP8266 usually has an onboard 10K or 12K resistor to ground, and we therefore have a suitable voltage divider to protect from the 5V of echo pin.

dofile(&quot;lib-ULTRASONIC.lua&quot;)

mysonar = Sonar.new(7, 8, 4)  -- trig, echo, echoLed

mysonar:run()

Multiple sonar devices can be configured. Just call Sonar.new() again for other pins.

run() may be joined into combination initialisation:

mysonar = Sonar.new(7,8):run()

Optionally, the library can use any LED to visibly show echo time, which is a useful diagnostic. Or parameter echoLed may be omitted.

run() will start the reading as a background task forever..  By default, the background reading repeats every 2000 mSec. run() can take one optional parameter, a custom repeat time in mSec.

You &quot;read&quot; like this:

dist = mysonar.read()

or

dist, timestamp = mysonar.read()

where dist is in cm and timestamp is system time of the instant of the hardware reading, from internal clock. The data received is the last reading made by the background task.   You may use Time(timestamp) to convert timestamp to readable format.

If you are really squeezed for memory, you can nil the Sonar.new after use.



lib-SMARTBTN.lua:

A smartbutton is a gpio with a pulldown button, where it measures the duration of press. Up to 3 different responses are called, the &quot;short press&quot; (&lt; 1 Sec), the &quot;1-Sec press&quot; and the &quot;3-Sec press&quot;.  Therefore that one button may be given 3 jobs to do!

dofile(&quot;lib-SMARTBTN.lua&quot;)

Supply the three callback functions to be executed when the smartbutton is pressed. Then create the smartbutton with its pin number and its 3 callbacks. (Any of the callbacks may be nil.)

Here is a  simple example, ** ** using pin D3, the &quot;flash button&quot;, and omitting the 1-sec response (even though a callback was coded)..

b0 = function () print (&quot;b0sec pressed&quot;) end

b1 = function () print (&quot;b1sec pressed&quot;) end

b3 = function () print (&quot;b3sec pressed&quot;) end

**smartButton( 3, b0, nil, b3)**    -- 1-sec callback omitted



lib-SERVO.lua:

&quot;Radio Control&quot; hobby servomotors usually need power supply of about 4.5 to 6 volts. There are 3 wires:

- .RED = nominally +4.5 (but +5V is OK)    Sometimes a red/orange  Usually the centre wire. But not always - depends on manufacturer, so be careful.
- .BLACK = GND   (sometimes brown)
- .3rd wire (ORANGE or YELLOW or WHITE) = pulse signal (from GPIO pin)

Reference:  https://www.princeton.edu/~mae412/TEXT/NTRAK2002/292-302.pdf

The ESP8266 NodeMCU board can probably supply enough 5V current for **one** servo without you resorting to a separate 5V supply. Several servos is too much for this method. Get a battery pack or other independent supply.

dofile(&quot;lib-SERVO.lua&quot;)

sv1 = Servo.new(pin, scaling)

then

sv1:set(newposn)

position is scaled 0 – 100,. Values above 100 are not actioned. Values below 0 cause the servo to stop.

Most servos sweep about 170-180 degrees. Scaling is an arbitrary calibration to map the 0-100 onto the sweep angle of the servo, and scaling defaults to 130 if omitted. You can experiment with other values, but about 140 is likely optimum. As low as 80 may be needed on some servos to avoid over-scan. Servos buzz and get unhappy if driven past their physical limits.

Current servo setting can be read:

currentposn = sv1:get()

Multiple servos may be created.



lib-ACCEL.lua:

The ACCEL library is additional support for triple-axis adxl345 I2C accelerometer. The NodeMCU Lua firmware build already has a basic driver for the adxl345, delivering X and Y and Z acceleration values. We have no evidence of the scaling of the values returned, but we should be entitled to consider that they are to the same calibration.  Refer http://nodemcu.readthedocs.io/en/dev/en/modules/adxl345/

Your project might want raw accelerometer output for jolt-detection, for example. However, for our purposes, let us assume:

- .that I2C is probably already initialised for OLED use.
- .that roll and pitch are more useful to us than uncalibrated raw aceleration values.

Initialise:

**i2c.setup(0, sda, scl, i2c.SLOW)**  -- if i2c not already set up

**adxl345.setup()**   -- but see init() below

So far, the lib-ACCEL library is not needed!  The library simply supply the math formulae for pitch and roll:

Here is a complete project to read the adxl345 every 3 seconds, use our 2 library formulae to calculate pitch and roll, and display those to the oled display:

**dofile(&quot;lib-OLED.lua&quot;)**   -- implicitly sets up the I2C for us. Yea!!

-- some &quot;builds&quot; of nodemcu lua image use init(), some use setup() syntax:

if adxl345.setup then

**   ** **adxl345.setup()  **

else

**   ** **adxl345.init(sda or 2,scl or 1)  **

end

dofile(&quot;lib-ACCEL.lua&quot;)

tmr.alarm(2, 3000, 1, function()

**   ** **local x, y ,z = adxl345.read()**

**   ** **print(string.format( &quot;X = %d, Y = %d, Z = %d&quot;, x, y, z ) )**

**   ** **pitch = axl\_pitch(y, z)**  -- inverted pcb

**   ** **roll = axl\_roll(x, z)**

**   ** **oled(&#39;y&#39;, { &quot;P &quot;..pitch, &quot;R &quot;..roll } )**

end )





lib-WIFIMON.lua:

A totally optional extension to wifi functionality. It simply monitors.the wifi and prints a message for each disconnection or reconnection that happens. It reports, but it does not change how wifi operates. Auto-reconnection is normal, and is not affected by WIFIMON.

dofile(&quot;lib-WIFIMON.lua&quot;)

lib-WIFIMON is based on information at:

http://nodemcu.readthedocs.io/en/dev/en/modules/wifi/#wifieventmon-module





lib-DEEPSLEEP.lua:

Normal operation of ESP8266 uses about 80mA (and peaks to about 300mA!), which results in short life per battery charge under battery operation. &quot;Deep Sleep&quot; is a very low power mode where most of the ESP8266 shuts down, leaving only the RTC module still keeping time in order to rewake the system later.

If the ESP8266 needs to do occasional tasks such as read a temperature at regular intervals, and to act on that sometimes (turn on fan? send message by wifi?), then putting it into deepsleep while otherwise idle can be an extremely large saving in battery use.  Deepsleep can be worthwhile even if each sleep is only a few seconds, but long sleeps like an hour or more can be very effective. Deepsleep has little meaning if you are using a power pack for supply.

You MUST connect D0 (GPIO16) to RST, otherwise the waking function fails. D0 is not a regular GPIO pin, it is a resetting pin coming from the RTC module. ESP-01 module does not expose D0, so deepsleep cannot be implemented on that.

Some &quot;nodeMCU&quot; style boards with USB chips continue to draw considerable board power even when the ESP itself sleeps, and deepsleep then is not the huge power saving benefit being sought. But some boards work well on deepsleep. You can test your own case.

During deep sleep the RTC still keeps time, and the RTC section also preserves some small block of memory. The RTC time and that RTC memory data can be preserved through the reset/wake process. In other respects, waking from deepsleep proceeds the same as any normal reset, ie, full initialising messages, and looking to start with init.lua.

The lib-DEEPSLEEP.lua module attempts to simplify deepsleep programming. It can be otherwise frustrating to program smoothly.

Load the library:

dofile(&quot;lib-DEEPSLEEP.lua&quot;)

This simple instruction in your project can then sleep:

**DEEPSLEEP(60)**  -- in seconds, so that sleeps 1 minute

Your project file of course needs to handle putting to sleep, and then handling life as normal after the waking.  And then deciding when to sleep again next time.

The ESP8266 has a maximun sleep time of just over one hour. If we wanted very long sleeps, we could sleep several times, waking between each pass just long enough to recognise we have more sleeps to go. The library can accommodate that easily, and so scheduling an (aggregated) sleep of say 12 hours can be done in one library call.

DEEPSLEEP(3600, 3, 12)

This would sleep for 12 hours as 12 passes x 60 minutes, even (the 3 parameter) skipping time-wasting wifi &amp; time sync in the quick intermediate wakeups.

The full function is:

DEEPSLEEP(sleeptime, startType, passes)

- .sleeptime is the time (secs) for each sleep &quot;pass&quot;
- .startType is how fully to wake up on each &quot;pass&quot; - default 0 if omitted
  -
    - ▪.0 = full start (with that 5 sec delay) at each wake from sleep
    - ▪.1 = full wifi start (but without delay) at each wake from sleep
    - ▪.3 = straight to project (no delay, no wifi) at wake between sleeps
- .passes = how many sleep passes are scheduled in the sequence – def 1

You may need to be mindful of just where in your project file you do the dofile(&quot;lib-DEEPSLEEP.lua&quot;), because while it loads, the library immediately examines whether it is partway through a sequence of passes. In which case it IMMEDIATELY returns to sleep for the next pass, and does not return control to your project.

You may note that our init.lua has some code relating to the deepsleep function. That section examines the stored &quot;startType&quot;, and tests whether an abbreviated startup is being requested.

If you are testing, and using multi-pass sleeps sequence, then on some boards pressing the reset button will terminate that pass, but the remaining passes will still proceed. It depends on the exact board schematic and that varies! (NodeMCU 1.0 – NO.  Lolin &quot;V3&quot; - YES)  Power off / power on always erases all RTC time and data, and results in clean normal start.

Because deepsleep timekeeping has poor accuracy, wakeup times may drift, and this can accumulate over multiple passes.  There **is scope** for a carefully constructed project file to be controlling and re-syncing real time intelligently. However, it is easier to simply accept a simple lower accuracy system. Just don&#39;t then expect to wake for your readings on every precise hour with a few seconds accuracy.

lib-TELNET.lua:

Runs a telnet server on ESP8266.  From another PC on your network, you get the same interpreter / commandline functionality as you see in ESPlorer. Any programmed Lua serial output, eg print( &quot;hello world&quot; ), duplicates to the telnet terminal.

You do NOT get ability to load lua files to the ESP via telnet.

Default port 2121, but preceding the library call with an override like this

tport=21

dofile(&quot;lib-TELNET.lua&quot;)

would then use your choice of port.

**Example on a linux PC:**  Open terminal and run telnet with correct IP and port. Execute some lua commands:

**brian@mypc ~ $**  **  telnet 192.168.1.212 21**

Trying 192.168.1.212...

Connected to 192.168.1.212.

Escape character is &#39;^]&#39;.

ESP8266 Telnet on

&gt;

&gt; =wifi.sta.getip()

192.168.1.212 255.255.255.0 192.168.1.254

&gt; =node.heap()

37760

**&gt; node.restart()    ****     -&gt; Bye !!!**

For security, ESPlorer will indicate **ESP8266 Telnet on** or **Telnet Fin** as PC logs on and off.

Telnet makes a very workable occasional substitute for ESPlorer after you have deployed your project.

Telnet library based on

https://github.com/nodemcu/nodemcu-firmware/blob/master/lua\_examples/telnet.lua



lib-LOGGER.lua:

The log is a plaintext file &quot;@log.var&quot; kept on flash filesystem on ESP2866. It records successive data entries of the format

Timestamp (readable)  Descriptor   Value

This file is not designed to be large, typically 20 to 40 lines long. Oldest data is dumped to allow new data. The log may be cleared simply by deleting the file, as it is recreated empty if found to be missing.  Unless explicitly cleared, the log is preserved over board resets, or over any lua file updates.

dofile(&quot;lib-LOGGER.lua&quot;)

Starts the logging system. As supplied, the library file writes one entry (description = &quot;Reset&quot;) each initialisation. Remove that line (bottom of file) if not needed.

The following functions are supported:

writeLog(description, value)

**viewLog()  **-- displays to ESPlorer screen, or to telnet terminal if used.

**newLog()**   -- deletes the logfile.

Any project may write to the logger.  The library &quot;lib-WEBSERV.lua&quot; also has functions to read the log at a remote web browser, or to clear the log.



lib-THINGSPEAK.lua:

This library allows data postings to your &quot;channel&quot; on ThingSpeak:

https://thingspeak.com

ThingSpeak is devoted to collecting repeat data, and allows analysis and plotting of the collected data. For paid subscription, very sophisticated analysis tools are available, including MatLab analytics. For a free subscription, basic but very usable plotting tools are still available.

Sign up for an account. Don&#39;t be persuaded that you need a paid subscription.  You then need to create a &quot;channel&quot; for data collection. Give it a channel name. Each channel is allowed up to 8 &quot;fields&quot;.

For example I have a channel called &quot;Brian1&quot; and it has an &quot;ID number&quot;. I have four fields activated: Field1 = Temp&quot;, Field2 = &quot;Lolin read32&quot;, Field4 = &quot;ESP01 vdd33&quot;, Field5 = &quot;Humidity&quot;.   I have been given (all on the website) two &quot;API Keys&quot;. Consider them as passwords. One is for Write, one for Read. Somewhere I have set my channel as viewable publicly by ID number (I can&#39;t find where I did it). Therefore, the Read API key is probably not needed.  I do need the Write API Key to let my library write data to the fields in my channel.

Firstly,  have your correct WRITE API KEY available.  Then in your project, load ThingSpeak like this:

dofile(&quot;lib-THINGSPEAK.lua&quot;)

APIKEY=&quot;JJJJJJ66666644WW&quot;

There is no constant connection from the ESP to ThingSpeak server. Each posting call makes a short-term network connection, and then closes it.

The library file has a single function call. It accepts one field per call.

postThingSpeak(fieldnumber, data, fieldname, callback\_function)

- .fieldnumber must be 1 up to 8.
- .data = the value you are sending
- .fieldname does not get transmitted. It simply prints to screen to look good.
- .callback is optional, but is useful if you want notice that the posting is over. (You might want to be posting several fields as quickly as possible?)

Here is a posting in your project of analog pin reading to ThingSpeak:

**   **  **volt = adc.read32;  **

**   ** **postThingSpeak(4, volt, &quot;Volt Reading&quot; )**

The library should display a success message to screen. On your web browser, use the following to see public view of your channel data (using YOUR channel number):

https://thingspeak.com/channels/999999

ThingSpeak viewers are also available on smartphones and tablets. Convenient apps on android include ThingView and Pocket IoT, and these can easily be configured to monitor data sent from the ESP8266 to ThingSpeak.

Basis for this library:

https://captain-slow.dk/2015/04/16/posting-to-thingspeak-with-esp8266-and-nodemcu/



lib-MQTT.lua:

The MQTT model is for two or more machines to transfer simple data packets (which might mean a command or might mean some data) between them. The data always passes through an intermediary server. To push data towards the server is called &quot;publishing&quot;, and each piece of data belongs to a &quot;topic&quot;. To collect any data from the server, another machine (or several) &quot;subscribes&quot; to the required topics, and the server sends that topic&#39;s data as it is available.

The main MQTT server (&quot;broker&quot;) is CloudMQTT, but the server technology is open source, and other servers exist. You can install your own, for example mosquitto on Raspberry Pi. Our library will presume you use a CloudMQTT account.  Adapt as you need if you want another server.

Each client machine connecting to the server will try to hold a constant connection.

Each machine may be small like an arduino, Raspberry Pi or ESP8266. It may be a PC. Or it may be a smartphone or tablet. A convenient MQTT app on android is MQTT Dashboard..

Edit your lib-MQTT file to list correctly your 4 credentials for MQTT login: BROKER, BRPORT, BRUSER, BRPWD.

There are three items to be coded in your project file **before** loading the library file:

1. **mqtt\_topics** = table of topic/qos pairs to be subscribed.
2. **mqtt\_ready()** - callback from library to project when MQTT has initialised
3. **mqtt\_recv(topic, data)** - callback from library to project when a (subscribed) message arrives

dofile(&quot;lib-MQTT.lua&quot;)

Then there is one call your project can make into the library:

1. **mqtt\_publish(topic, data)** - call from project into library to publish a payload to a topic

Typical use of mqtt\_ready(). Start a 20-second repeat for reading LDR value and publishing that:

function mqtt\_ready()

**     **** tmr.alarm(2, 20000, 1, function() mqtt\_publish(&quot;LDR&quot;, readLDR())  end )**

end

Typical subscribed topics list in your project:

**mqtt\_topics = {Led1=0, Led2=0, OledMsg=0, testButn=0}  ** -- qos all 0

Typical callback to handle incoming messages on those subscribed topics:

function mqtt\_recv(topic, data)

**       ** **if topic == &quot;Led1&quot; then gpio.write(4,data==&quot;0&quot; and 0 or 1) end**

**       ** **if topic == &quot;Led2&quot; then gpio.write(0,data==&quot;0&quot; and 0 or 1) end**

**       ** **if topic == &quot;OledMsg&quot; then oled(&quot;j&quot;,data) end**

**       ** **if topic == &quot;testButn&quot; then mqtt\_publish(&quot;Button&quot;, gpio.read(3))  end      **

end

Note that last (testButn) incoming topic. Our response here is to send back (publish) our &quot;Button&quot; data to the other end. So this looks like a poll transaction. The other end make a read request. We make the reading, and send that back to the other end.



lib-WEBSERV.lua:

This library starts a webserver. You can view the web page from any browser having network access.  Page title and some page controls are automatic.

By default, the logger system (if it is loaded) has view-log and delete-log buttons on the page. This can be suppressed if variable **WS\_suppressLogger** is true.

if variable **WS\_pageRefresh** =(number xx), then the web page will auto-refresh in the browser every xx seconds.

If variable **WS\_tnet** is true, primitive telnet controls will be activated on the browser page. Enter your input to the box and press enter. Then press See Result if you want to view any response that the ESPlorer screen would have shown you.  Eg &quot;=node.heap()&quot; into box.

Followed by See Result, to view the &quot;32763&quot; reply.

The library includes one utility function **button(vbl, value, label, colour)** that builds a boilerplate HTML button.

In general, an empty web page is useless. Your project needs to implement a function **WS\_buildpage(\_GET)** to add custom HTML controls to the page.

Your code should build (into the global variable webPage) the HTML fragments to display some control buttons the user can click. The parameter \_GET brings a table with key:value pair corresponding to the user&#39;s last button click on their browser.  The following project codes a HTML clickable pair of buttons. It also reacts to user&#39;s last click to turn a GPIO (led on gpio16/D0) on or off. We are looking for the key value pairs **pin:ON1** or **pin:OFF1** because that&#39;s the way we coded our buttons.

function WS\_buildpage(\_GET)

**       ** **if (\_GET.pin == &quot;ON1&quot;) then**   -- examine last button click

**               **** gpio.write(led1, gpio.HIGH)  ** -- and set gpio accordingly

**       ** **elseif (\_GET.pin == &quot;OFF1&quot;) then**

**               **** gpio.write(led1, gpio.LOW)**

**       **  **end**

**     **   -- now code the buttons again for next display

**       ** **webPage = webPage.. &quot;&lt;p&gt;GPI016 &quot; .. button(&quot;pin&quot;, &quot;ON1&quot;, &quot;HIGH&quot;) ..**

**                       ** **&quot; &quot; .. button(&quot;pin&quot;, &quot;OFF1&quot;, &quot;LOW&quot;) .. &quot; redled&lt;/p&gt;\n&quot;**

**       ** **if gpio.read(led1) == 0 then**

**             **  **webPage = webPage .. &quot;&lt;p&gt;RED  LED ON &lt;/p&gt;\n&quot;** – feedback for user

**       **  **end**

end

WS\_suppressLogger = true

dofile(&quot;lib-WEBSERV.lua&quot;)



lib-GPIO25.lua:

Uses a MCP23017 chip on I2C address 0x20 to add **new GPIO numbers 9 to 24**. GPIO syntax remains the same:

**i2c.setup(0, sda, scl, i2c.SLOW)**  -- if needed

dofile(&quot;lib-GPIO25.lua&quot;)

gpio.mode(17,gpio.OUTPUT)

gpio.write(17, gpio.HIGH)

That code assumes I2C needs initialising. If OLED for example has already initialised I2C, omit the first line.



lib-ADC8.lua

Uses CD4051 analog multiplexer chip to expand the one **ADC to 8 channels** (0 – 7). Requires 3 digital GPIO pins as addressing to the CD4051. (If GPIO25 is installed first, the expanded gpio pins could be used.)

Default addressing GPIOs if omitted are D6 D7 D8. Or specifying just one will assume a consecutive three. Use adc.init8() to enable the extra channels.

Adc reading syntax is same style as the original one channel.

dofile(&quot;lib-ADC8.lua&quot;)

adc.init8(6,7,8)

v5 = adc.read(5)



Brian Lavery

esuite@blavery.com

V0.3

26 Aug 2017
