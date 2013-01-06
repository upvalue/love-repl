-- repl/init.lua - an interactive lua repl for love games
-- Copyright (c) 2013 ioddly
-- Released under the Boost License: <http://www.boost.org/LICENSE_1_0.txt>

-- Module
local repl = {
  toggle_key = '`',
  clear_key = 'escape',
  padding_left = 5,
  max_lines = 1000,
  max_history = 1000,
  font = nil,
  screenshot = false,
  background = false,
}
-- True when open, false when closed
local toggled = false
-- Console contents
local lines, history
-- Line that is currently being edited
local editline = ""
-- Current position in history
local histpos = 0
-- Circular buffer functionality
local cursor, entries = 2, 1
-- Save keyboard settings
local kpdelay, kpinterval
-- Line offset (in case of scrolling up and down)
local offset = 1

-- Circular buffer functionality
local buffer = {}

function buffer:new(ob)
  local o = ob or {}
  o.entries = #o
  o.cursor = #o + 1
  o.max = 10
  setmetatable(o, self)
  self.__index = self
  return o
end

function buffer:append(entry)
  if self[self.cursor] then
    self[self.cursor] = entry
  else
    table.insert(self, entry)
  end
  self.cursor = self.cursor + 1
  if self.cursor == self.max + 1 then
    self.cursor = 1
  end
  if self.entries ~= self.max then
    self.entries = self.entries + 1
  end
end

function buffer:get(idx)
  -- Allow negative indexes
  if idx < 0 then
    idx = (self.entries + idx) + 1
  end

  if self.entries == self.max then
    local c = self.cursor + idx - 1
    if c > self.max then
      c = c - self.max
    end
    return self[c]
  else
    return self[idx]
  end
end

local get_history = function()
  if histpos > 0 then
    editline = history:get(-histpos)
  end
end

function repl.initialize()
  lines = buffer:new({{false, "! love-repl"}})
  lines.max = repl.max_lines
  history = buffer:new()
  history.max = repl.max_history
  -- Expose these in case somebody wants to use them
  repl.lines = lines
  repl.history = history

  if not repl.font then
    repl.font = love.graphics.newFont(12)
  end
  repl.line_height = repl.font:getHeight()
  
  -- TODO: Redundant with some drawing code.
  local _, height = love.graphics.getMode()
  repl.display_lines = math.floor((height - (repl.line_height * 2)) / repl.line_height)
end

function repl.toggle()
  toggled = not toggled
  if toggled then
    kpdelay, kpinterval = love.keyboard.getKeyRepeat()
    love.keyboard.setKeyRepeat(0.01, 0.1)
    if repl.screenshot then
      repl.background = love.graphics.newImage(love.graphics.newScreenshot())
    end
  else
    love.keyboard.setKeyRepeat(kpdelay, kpinterval)
    repl.on_close()
  end
end

function repl.toggled()
  return toggled
end

function repl.on_close() end

function repl.print(text)
  repl.append(false, text)
end

function repl.eval(text)
  -- Evaluate string
  if text:sub(0,1) == '=' then
    text = 'return ' .. text:sub(2)
  end
  local func, err = loadstring(text)
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
      repl.append(true, text)
      repl.print(ret)
      return true
    else
      repl.print('! Evaluation error: ' .. ret)
    end
  end
  return false
end

function repl.mousepressed(x, y, button)
  if button == 'wu' then
    if offset <= (lines.entries - repl.display_lines) then 
      offset = offset + 1
    end
  elseif button == 'wd' then
    if offset - 1 ~= 0 then
      offset = offset - 1
    end
  end
end

function repl.keypressed(k, u)
  if k == 'backspace' then
    editline = editline:sub(0, #editline - 1)
  elseif k == repl.clear_key then
    editline = ''
    histpos = 1
  elseif k == 'return' then
    offset = 1
    if editline == '' then return end
    if repl.eval(editline) then
      if editline:sub(0,1) == '=' then
        history:append('return ' .. editline:sub(2))
      else
        history:append(editline)
      end
      editline = ''
    end
  elseif k == 'up' then
    if histpos + 1 <= history.entries then
      histpos = histpos + 1
      get_history()
    end
  elseif k == 'down' then
    if histpos - 1 > 0 then
      histpos = histpos - 1
      get_history()
    else
      histpos = 0 
      editline = ''
    end
  elseif k == repl.toggle_key then
    repl.toggle()
  else
    if u > 31 and u < 127 then
      editline = editline .. string.char(u)
    end
  end
end

-- Circular buffer functionality
function repl.get_line(idx)
  return lines:get(idx)
 end

function repl.append(history, value)
  lines:append({history, tostring(value)})
end

function repl.draw()
  if repl.screenshot then
    love.graphics.setColor(100, 100, 100, 100)
    love.graphics.draw(repl.background, 0, 0)
    love.graphics.setColor(255, 255, 255, 255)
  elseif repl.background then
    love.graphics.draw(repl.background, 0, 0)
  else
    love.graphics.clear()
  end

  local _, height = love.graphics.getMode()
  local lheight = repl.line_height
  -- Leave some room for text entry
  local limit = height - (lheight * 2)
  local possible_lines = math.floor(limit / lheight)
  -- min(possible_lines, entries)
  local max = math.min(possible_lines, lines.entries)

  for i = offset, possible_lines + offset do
    local line = repl.get_line(-i)
    if line == nil then break end
    local text = line[1] and ('> ' .. line[2]) or line[2]
    love.graphics.print(text, repl.padding_left, limit - (lheight * (i - offset + 1 )))
  end

  -- print edit line
  love.graphics.print("> " .. editline, repl.padding_left, limit)
end

return repl
