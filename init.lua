-- repl/init.lua - an interactive lua repl for love games
-- Copyright (c) 2013 ioddly
-- Released under the Boost License: <http://www.boost.org/LICENSE_1_0.txt>

-- Module
local repl = {togglekey = '`', padding_left = 5, max = 10, darken = false}
-- True when open, false when closed
local toggled = false
-- Console contents
local lines = {
  {false, "! love-repl"}
}
-- Line that is currently being edited
local editline = ""

repl.effect = love.graphics.newPixelEffect [[
  vec4 effect(vec4 color, Image texture, vec2 tcoords, vec2 pcoords)
  {
    vec4 pixel = Texel(texture, tcoords);
    pixel.r = pixel.r / 2;
    pixel.g = pixel.g / 2;
    pixel.b = pixel.b / 2;
    return pixel;
  }
]]

-- Save keyboard settings
local kpdelay, kpinterval, pe

function repl.toggle()
  toggled = not toggled
  if toggled then
    kpdelay, kpinterval = love.keyboard.getKeyRepeat()
    pe = love.graphics.getPixelEffect()
    love.keyboard.setKeyRepeat(0.01, 0.1)
    if repl.darken then love.graphics.setPixelEffect(repl.effect) end
  else
    love.keyboard.setKeyRepeat(kpdelay, kpinterval)
    love.graphics.setPixelEffect(pe)
    repl.on_close()
  end
end

function repl.toggled()
  return toggled
end

function repl.on_close() end

function repl.append(history, value)
  table.insert(lines, { history, tostring(value) })
end

function repl.print(text)
  repl.append(false, text)
end

function repl.keypress(k, u)
  if k == 'backspace' then
    editline = editline:sub(0, #editline - 1)
  elseif k == 'return' then
    -- Evaluate string
    if editline:sub(0,1) == '=' then
      editline = 'return ' .. editline:sub(2)
    end
    local func, err = loadstring(editline)
    -- Compilation error
    if not func then
      if err then
        repl.print('! Compilation error: ' .. err)
      else
        repl.print('! Unknown compilation error')
      end
    else
      -- Try evaluating
      local status, ret = pcall(func)
      if status then
        repl.append(true, editline)
        repl.print(ret)
        editline = '' 
      else
        repl.print('! Evaluation error: ' .. ret)
      end
    end
  elseif k == repl.togglekey then
    repl.toggle()
  else
    if u > 31 and u < 127 then
      editline = editline .. string.char(u)
    end
  end
end

function repl.get_line(idx)
  return lines[idx]
end

function repl.draw()
  if repl.darken then
    love.graphics.setPixelEffect(nil)
  end

  local _, height = love.graphics.getMode()
  local lheight = love.graphics.getFont():getHeight()
  -- Leave some room for text entry
  local limit = height - (lheight * 2)
  local possible_lines = math.floor(limit / lheight)

  for i = 1, possible_lines do
    local idx = #lines - i + 1 
    if idx < 1 then
      break
    end
    local line = repl.get_line(idx)
    local text = line[1] and line[2] or ('> ' .. line[2])
    love.graphics.print(text, repl.padding_left, limit - (lheight * i))
  end

  -- print edit line
  love.graphics.print("> " .. editline, repl.padding_left, limit)

  if repl.darken then
    love.graphics.setPixelEffect(repl.effect)
  end
end

return repl

