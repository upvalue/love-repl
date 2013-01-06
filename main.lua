-- Load REPL library. In your game, you would require('love-repl') (or whatever you name the source directory)
local repl = require('init') 
local background

function love.load()
  love.graphics.setMode(800, 600)
  -- Enable darkening effect
  repl.darken = true
  background = love.graphics.newImage('background.jpg')
end

function love.keypressed(k, u)
  if repl.toggled() then
    repl.keypress(k, u)
    return
  end
  -- Your key handling code here

  -- You'll need a key bound to open the REPL, ` by default
  -- If you want to change it, set repl.togglekey to that key before doing so
  -- Note that love-repl doesn't care about key modifiers like ctrl, shift, etc.
  -- So if you want your toggle to be Shift-F8, that's fine, but set togglekey to 'f8'.

  if k == '`' then
    repl.toggle()
  end
end

function love.draw()
  -- Your rendering code here
  -- You don't have to render under the REPL if you don't want to, but there's a pretty ballin' darkening effect
  love.graphics.draw(background, 0, 0)
  love.graphics.printf("Hit ` to open REPL", 0, 0, 800)
  if repl.toggled() then
    repl.draw()
    return
  end
end

function love.update()
  -- If the REPL is open, you probably don't want to update your game
  if repl.toggled() then
    return
  end
end
