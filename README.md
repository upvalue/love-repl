Magic-free in-game REPL for the Love game engine. Released under the Boost 1.0 license.

I say magic free because it does not override any Love functions, but it does require you to add hooks into your code
in order to work.

See main.lua for an example. The background used in the demo is from [David Brown on
flickr](http://www.flickr.com/photos/shadowsofthesun/), used under the Creative Commons license.

![console closed](http://i.imgur.com/y189M.png) ![console open](http://i.imgur.com/FUvf6.png)

### Use

Press enter to evaluate the statement, backspace to, well, backspace and escape to clear the current line. Use the up
and down arrow keys to navigate through history. Like the
normal Lua REPL, if you want to evaluate an expression (such as "true" or "555"), you must start the line with '='

### Functions

##### repl.initialize()

Should be called during love.load() to initialize the module, but after specifying any settings (such as max lines),
and after setting Love's graphical mode.

##### repl.toggle()

Toggle the REPL.

##### repl.toggled() : boolean

Returns true if the REPL has been toggled.

##### repl.eval(text : string)

Enter and evaluate the text at the REPL. Normally triggered by a user entering text, but can be called directly from
code if desired. Returns true if evaluation was successful, false if not.

##### repl.print(value)

Print value to the REPL. Great for debug messages. REPL does not need to be open for this to work.

##### repl.keypressed(k, u)

Use this function to pass key presses through to the REPL.

##### repl.mousepressed(x, y, button)

Guess.

##### repl.draw()

Render the REPL.

### Variables

##### repl.font : Font

The font to use when rendering. Vera Sans 12pt by default.

##### repl.screenshot = true

If true, take a screenshot when toggled and set repl.background to a darkened version of it.

##### repl.background : Drawable

Image to use as REPL background. If neither this or screenshot is set, love-repl will clear to black.

##### repl.max_lines = 1000

The maximum number of lines to keep. Must be set before initialize() is called. Includes both user-entered and program
generated lines.

##### repl.max_history = 100

The maximum number of history lines to keep. Must be set before initialize() is called.

##### repl.toggle_key = "`" 

The Love KeyConstant that will cause the REPL to close itself. 

##### repl.clear_key = "escape"

The Love KeyConstant that will clear the current line.

##### repl.on_close : function

A hook that will be called when the REPL is closed. 

### Issues

- No word wrapping (will complicate rendering a bit)
- More complex padding on the REPL
- Fancier line editing capability (e.g. a cursor, backward-word and forward-word)
