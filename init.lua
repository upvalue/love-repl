-- love-repl - an interactive lua repl for love games
-- Copyright (c) 2013 ioddly
-- Released under the Boost License: <http://www.boost.org/LICENSE_1_0.txt>

-- Module
local repl = {
  toggle_key = '`',
  clear_key = 'escape',
  padding_left = 10,
  max_lines = 1000,
  max_history = 1000,
  font = nil,
  screenshot = true,
  background = false,
  dark_factor = 0.6,
  dirty = true
}
-- How many pixels of padding are on either side
local PADDING = 20
-- How many pixels are required to display a row
local ROW_HEIGHT
-- Maximum amount of rows that can be displayed on the screen
local DISPLAY_ROWS
-- Width of the display available for text, in pixels
local DISPLAY_WIDTH
-- True when open, false when closed
local toggled = false
-- Console contents
-- History is just a list of strings
local history
-- List of {boolean, string} where boolean is true if the string is part of user-navigable history (a > will be prepended before rendering if true)
local lines
-- Line that is currently being edited
local editline = ""
-- Location in the editline
local cursor = 0
-- Current position in history
local histpos = 0
-- Save the game's keyboard settings
local kprepeat
-- Line display offset (in case of scrolling up and down)
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

function repl.initialize()
  lines = buffer:new({"! love-repl"})
  lines.max = repl.max_lines
  history = buffer:new()
  history.max = repl.max_history
  -- Expose these in case somebody wants to use them
  repl.lines = lines
  repl.history = history

  if not repl.font then
    repl.font = love.graphics.newFont(12)
  end
  ROW_HEIGHT = repl.font:getHeight()
  
  local width, height = love.window.getMode()
  DISPLAY_WIDTH = width - PADDING
  DISPLAY_ROWS = math.floor((height - (ROW_HEIGHT * 2)) / ROW_HEIGHT)
end

function repl.toggle()
  toggled = not toggled
  if toggled then
    kprepeat = love.keyboard.hasKeyRepeat()
    love.keyboard.setKeyRepeat(true)
    if repl.screenshot then
      repl.background = love.graphics.newImage(love.graphics.newScreenshot())
    end
  else
    love.keyboard.setKeyRepeat(kprepeat)
    repl.on_close()
  end
end

function repl.toggled()
  return toggled
end

function repl.on_close() end

function repl.append(history, value)
  value = tostring(value)
  lines:append(history and ('> ' .. value) or value)
end

function repl.print(text)
  repl.append(false, text)
end

local function pack(...) return {...} end

function repl.eval(text, add_to_history)
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
    local result = pack(pcall(func))
    local ret = result[2]
    if result[1] then
      repl.append(true, text)
      local results, i = tostring(result[2]), 3
      if add_to_history then
        if text:sub(0,1) == '=' then
          history:append('return ' .. text:sub(2))
        else
          history:append(text)
        end
      end
      while i <= #result do
        results = results .. ', ' .. tostring(result[i])
        i = i + 1
      end
      repl.print(results)
      return true
    else
      repl.print('! Evaluation error: ' .. ret)
    end
  end
  return false
end

function repl.mousepressed(x, y, button)
  if button == 'wu' then
    if offset <= (lines.entries - DISPLAY_ROWS) then 
      offset = offset + 1
    end
  elseif button == 'wd' then
    if offset - 1 ~= 0 then
      offset = offset - 1
    end
  end
end

-- Line editing functionality and key handling

local function reset_editline()
  editline = ''
  cursor = 0
  prompt_prefix = ''
end

local function get_history()
  if histpos > 0 then
    editline = history:get(-histpos)
    cursor = #editline
  end
end

local function ctrlp() return love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') end
local function shiftp() return love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') end

function repl.keypressed(k, isrepeat)
  -- Line editing
  if k == 'backspace' then
    editline = editline:sub(0, cursor - 1) .. editline:sub(cursor + 1, #editline)
    if cursor > 0 then 
      cursor = cursor - 1
    end
  elseif k == 'delete' then
    editline = editline:sub(0, cursor) .. editline:sub(cursor + 2, #editline)
  elseif ctrlp() and k == 'a' then
    cursor = 0
  elseif ctrlp() and k == 'e' then
    cursor = #editline
  elseif k == 'return' then
    histpos = 0
    offset = 1
    if editline == '' then return end
    if repl.eval(editline, true) then
      reset_editline()
    end
  elseif k == 'up' then
    if histpos + 1 <= history.entries then
      histpos = histpos + 1
      get_history()
    end
  -- Navigation
  elseif k == 'home' then
    offset = math.max(1, lines.entries - DISPLAY_ROWS + 1)
  elseif k == 'end' then
    offset = 1
  elseif k == 'pageup' then
    offset = math.min(lines.entries - DISPLAY_ROWS + 1, offset + DISPLAY_ROWS)
  elseif k == 'pagedown' then
    offset = math.max(1, offset - DISPLAY_ROWS)
  elseif k == repl.clear_key then
    reset_editline()
  elseif k == 'down' then
    if histpos - 1 > 0 then
      histpos = histpos - 1
      get_history()
    else
      histpos = 0 
      reset_editline()
    end
  elseif k == 'left' and cursor > 0 then
    cursor = cursor - 1
  elseif k == 'right' and cursor ~= #editline then
    cursor = cursor + 1
  elseif k == repl.toggle_key then
    repl.toggle()
    assert(toggled == false)
  end
end

function repl.textinput(t)
  if t == repl.toggle_key then return end
  editline = editline:sub(0, cursor) .. t .. editline:sub(cursor + 1)
  cursor = cursor + 1
end

-- Rendering

function repl.draw()
  -- Draw background
  if repl.screenshot then
    local c = 255 * repl.dark_factor
    love.graphics.setColor(c,c,c,c)
    love.graphics.draw(repl.background, 0, 0)
    love.graphics.setColor(255, 255, 255, 255)
  elseif repl.background then
    love.graphics.draw(repl.background, 0, 0)
  else
    love.graphics.clear()
  end

  local lheight = ROW_HEIGHT

  -- Leave some room for text entry
  local width, height = love.window.getMode()
  local limit = height - (lheight * 2)

  -- print edit line
  local prefix = "> "
  local ln = prefix .. editline
  love.graphics.print(ln, repl.padding_left, limit)

  -- draw cursor
  local cx, cy = repl.padding_left + 1 + repl.font:getWidth(prefix) + repl.font:getWidth(editline:sub(0, cursor)), limit + repl.font:getHeight() + 2
  love.graphics.line(cx, cy, cx + 5, cy)

  -- draw history
  for i = offset, DISPLAY_ROWS + offset do
    local line = lines:get(-i)
    if line == nil then break end
    love.graphics.print(line, repl.padding_left, limit - (lheight * (i - offset + 1 )))
  end

  -- draw scroll bar
  -- height is percentage of the possible lines
  local bar_height = math.min(100, (DISPLAY_ROWS * 100) / lines.entries)
  -- convert to pixels (percentage of screen height, minus 10px padding)
  local bar_height_pixels = (bar_height * (height - 10)) / 100

  local sx = width - 5
  -- Handle the case where there are less actual lines than display rows
  if bar_height_pixels >= height - 10 then
    love.graphics.line(sx, 5, sx, height - 5)
  else
    -- now determine location on the screen by taking the offset in history and converting it first to a percentage of total lines and then a pixel offset on the screen
    local bar_end = (offset * 100) / lines.entries
    bar_end = ((height - 10) * bar_end) / 100
    bar_end = height - bar_end

    local bar_begin = bar_end - bar_height_pixels
    -- Handle overflows
    if bar_begin < 5 then
      love.graphics.line(sx, 5, sx, bar_height_pixels)
    elseif bar_end > height - 5 then
      love.graphics.line(sx, height - 5 - bar_height_pixels, sx, height - 5)
    else
      love.graphics.line(sx, bar_begin, sx, bar_end)
    end
    --love.graphics.line(width - 5, bar_begin, width - 5, math.max(bar_end, height - 5))
  end
end

return repl
