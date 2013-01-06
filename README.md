love-repl

Magic-free in-game REPL for the Love game engine. Released under the Boost 1.0 license.

I say magic free because it does not override any Love functions, but it does require you to add hooks into your code
in order to work.

See main.lua for an example. The background used in the demo is from [David Brown on
flickr](http://www.flickr.com/photos/shadowsofthesun/), used under the Creative Commons license.

### Use

Press enter to evaluate the statement, backspace to, well, backspace and escape to clear the current line.  Like the
normal Lua REPL, if you want to evaluate an expression (such as "true" or "555"), you must start the line with '='

### Functions

    repl.initialize()

Should be called during love.load() to initialize the module, but after specifying any settings (such as max lines).

    repl.toggle()

Toggle the REPL.

    repl.toggled() : boolean


Returns true if the REPL has been toggled.

    repl.eval(<text : string>)

Enter and evaluate the text at the REPL. Normally triggered by a user entering text, but can be called directly from
code if desired. Returns true if evaluation was successful, false if not.

    repl.print(<text : string>)

Print text to the REPL. Great for debug messages. REPL does not need to be open for this to work.

    repl.keypressed(k, u)

Use this function to pass key presses through to the REPL.

    repl.draw()

Render the REPL.

### Variables

    repl.max_lines = 1000

The maximum number of lines to keep. Must be set before initialize() is called. Includes both user-entered and program
generated lines.

    repl.max_history = 100

The maximum number of history lines to keep. Must be set before initialize() is called.

    repl.toggle_key = "`" 

The Love KeyConstant that will cause the REPL to close itself. 

    repl.clear_key = "escape"

The Love KeyConstant that will clear the current line.

    repl.on_close : function

A hook that will be called when the REPL is closed. 

### Issues

- No word wrapping (will complicate rendering a bit)
- History, more line editing features
- More complex padding on the REPL
