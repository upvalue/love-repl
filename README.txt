love-repl

Magic-free in-game REPL for the Love game engine. Released under the Boost 1.0 license.

I say magic free because it does not override any Love functions, but it does require you to add hooks into your code
in order to work.

See main.lua for an example. The background used in the image is from [David Brown on
flickr](http://www.flickr.com/photos/shadowsofthesun/), used under the creative commons license.

### Functions

```repl.toggle()```

Toggle the REPL.

```repl.toggled() : boolean```

Returns true if the REPL has been toggled.

```repl.print(<text : string>)```

Print text to the REPL. Great for debug messages. REPL does not need to be open for this to work.

```repl.keypress(k, u)```

Use this function to pass key presses through to the REPL.

```repl.draw()```

Render the REPL.

### Variables

```repl.max : number = 1000```

The maximum number of lines that will be kept.

```repl.togglekey : KeyConstant = "`" ```

The Love KeyConstant that will cause the REPL to close itself. 

```repl.on_close : function```

A hook that will be called when the REPL is closed. 

```repl.padding_left : number```

### Possible Issues

- No word wrapping (will complicate rendering a bit)
