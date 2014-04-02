Magic-free in-game REPL for the Love game engine. Released under the Boost 1.0 license. (Credit is not required but
would be appreciated)

I say magic free because it does not override any Love functions, but it does require you to add hooks into your code
in order to work.

See main.lua for an example. The background used in the demo is from [David Brown on
flickr](http://www.flickr.com/photos/shadowsofthesun/), used under the Creative Commons license.

![console closed](http://i.imgur.com/y189M.png) ![console open](http://i.imgur.com/FUvf6.png)

### Use

- Enter: Evaluate line
- Left/Right: Move cursor in line
- Backspace: Delete letter behind cursor
- Delete: Delete letter at cursor
- Ctrl-A: Beginning of line
- Ctrl-E: End of line
- Escape: Clear current line
- Up/Down: Navigate through history for a line to edit
- Mouse wheel: Scroll through history
- Home: Scroll to top
- End: Scroll to bottom
- Page up: Scroll up a page
- Page down: Scroll down a page
- Backtick (`): Default toggle key

Note that like the normal Lua console, if you want to evaluate an expression (such as "true" or "555"), you must start
the line with '=', otherwise it will be an error.

### Functions

##### repl.initialize()

Should be called during love.load() to initialize the module, but after specifying any settings (such as max lines),
and after setting Love's graphical mode.

##### repl.toggle()

Toggle the REPL.

##### repl.toggled() : boolean

Returns true if the REPL has been toggled.

##### repl.eval(text : string, add_to_history : boolean) : boolean

Enter and evaluate TEXT at the REPL. Normally triggered by a user entering text, but can be called directly from code
if desired. If ADD_TO_HISTORY is true, the line will be added to the user-navigable history if it is successfully
evaluated. Returns true if evaluation was successful, false if not.  

##### repl.print(value)

Print value to the REPL. Great for debug messages. REPL does not need to be open for this to work.

##### repl.keypressed(k, isrepeat)

Use this function to pass key presses through to the REPL.

##### repl.mousepressed(x, y, button)
##### repl.textinput(t)

Guess.

##### repl.draw()

Render the REPL.

### Variables

##### repl.font : Font

The font to use when rendering. Vera Sans 12pt by default.

##### repl.screenshot = true

If true, take a screenshot when toggled and set repl.background to a darkened version of it.

##### repl.dark_factor = 0.6

The amount by which the background will be darkened, lower is darker. Should be between 0 and 1.

##### repl.background : Drawable

Image to use as REPL background. If neither this or screenshot is set, love-repl will clear to black.

##### repl.max_lines = 1000

The maximum number of lines to keep. Must be set before initialize() is called. Includes both user-entered and program
generated lines.

##### repl.max_history = 1000

The maximum number of history lines to keep. Must be set before initialize() is called.

##### repl.toggle_key = "f8" 

The Love KeyConstant that will cause the REPL to close itself. 

##### repl.clear_key = "escape"

The Love KeyConstant that will clear the current line.

##### repl.on_close : function

A hook that will be called when the REPL is closed. 

### Issues

- No word wrapping
