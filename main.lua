-- Load REPL library. In your game, you would require('love-repl') (or whatever you name the source directory)
local repl = require('init') 
local background

function love.load()
  love.window.setMode(800, 600)
  repl.initialize()
  -- Fill REPL with some example trash
  repl.eval("=1", true)
  repl.eval("=2", true)
  repl.eval("=3", true)
  for i = 4, 45 do
    repl.print(i)
  end
  repl.print("This line is so long that it will have to be padded. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
  background = love.graphics.newImage('background.jpg')
end

function love.mousepressed(x, y, button)
  if repl.toggled() then
    repl.mousepressed(x, y, button)
    return
  end
end

function love.keypressed(k, u)
  if repl.toggled() then
    repl.keypressed(k, u)
    return
  end
  -- Your key handling code here

  -- You'll need a key bound to open the REPL, ` by default
  -- If you want to change it, set repl.toggle_key to that key before doing so
  -- Note that love-repl doesn't care about key modifiers like ctrl, shift, etc.
  -- So if you want your toggle to be Shift-F8, that's fine, but set toggle_key to 'f8'.

  if k == 'f8' then
    repl.toggle()
  end
end

function love.textinput(t)
  if repl.toggled() then
    repl.textinput(t)
  end
end

function love.draw()
  if repl.toggled() then
    repl.draw()
  else
    -- Your rendering code here
    love.graphics.draw(background, 0, 0)
    love.graphics.printf("Hit ` to open REPL", 0, 0, 800)
  end
end

function love.update()
  -- If the REPL is open, you probably don't want to update your game
  if repl.toggled() then
    return
  end
end
