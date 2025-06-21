local pause = {}

local gamestate = require("gamestate")
local nineslice = require("nineslice")
local audio = require("audio")

local paused = false
local selectedIndex = 1
local buttonFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 24)
local uiBoxImage = love.graphics.newImage("Assets/UI_box.png")

local buttons = {
   { label = "Resume", action = function() pause.toggle() end },
   { label = "Settings", action = function()
         pause.toggle()
         gamestate.setState("settingsscreen")
		 audio.playSFX("Click")
     end
   },
   { label = "Quit to Title", action = function()
         pause.toggle()
         gamestate.setState("titlescreen")
		 audio.playSFX("Click")
     end
   },
}

function pause.isActive()
   return paused
end

function pause.toggle()
	paused = not paused
	
	if paused then
		audio.duckMusic()
	else
		audio.restoreMusic()
	end
end

function pause.handleKey(key)
   if key == "escape" then
      pause.toggle()
      return true
   end

   return false
end

function pause.handleGamepadPressed(joystick, button)
   if button == "start" then
      pause.toggle()
      return true
   end
   return false
end

function pause.mousepressed(x, y, button)
   if not paused then return false end
   for i, b in ipairs(buttons) do
      local bx = love.graphics.getWidth() / 2 - 120
      local by = 160 + (i - 1) * 60
      if x >= bx and x <= bx + 240 and y >= by and y <= by + 48 then
         b.action()
         return true
      end
   end
   return true
end

function pause.draw()
   local w, h = love.graphics.getWidth(), love.graphics.getHeight()

   love.graphics.setColor(0, 0, 0, 0.6)
   love.graphics.rectangle("fill", 0, 0, w, h)

   love.graphics.setFont(buttonFont)
   love.graphics.setColor(1, 1, 1)
   love.graphics.printf("Paused", 0, 100, w, "center")

   for i, b in ipairs(buttons) do
      local bx = w / 2 - 120
      local by = 160 + (i - 1) * 60
	  local mx, my = love.mouse.getPosition()
	  local isHovered = mx >= bx and mx <= bx + 240 and my >= by and my <= by + 48

      love.graphics.setColor(1, 1, 1)
      nineslice.draw(uiBoxImage, bx, by, 240, 48)

      local color = isHovered and {1, 1, 0.8} or {0.8, 0.9, 1}
      love.graphics.setColor(color)
      love.graphics.printf(b.label, bx, by + 10, 240, "center")
   end
end

return pause