local titlescreen = {}

local gamestate = require("gamestate")
local nineslice = require("nineslice")
local audio = require("audio")

-- === Assets ===
local uiBoxImage = love.graphics.newImage("Assets/UI_box.png")
local titleFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 96)
local buttonFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 24)

-- Starfield
local starfield = love.graphics.newImage("Assets/Backgrounds/starfield.png")
local starfieldScroll = 0
local starfieldSpeed = 30

-- === Button Definitions ===
local buttons = {
   {
      label = "Play",
      action = function() gamestate.setState("gamescreen") audio.playSFX("Click") end,
   },
   {
      label = "Settings",
      action = function() gamestate.setState("settingsscreen") audio.playSFX("Click") end,
   },
   {
      label = "Quit",
      action = function() love.event.quit() audio.playSFX("Click") end,
   }
}

local buttonWidth, buttonHeight = 160, 48
local buttonSpacing = 20

local function getButtonX()
   return love.graphics.getWidth() / 2 - buttonWidth / 2
end

local function getButtonY(index)
   return love.graphics.getHeight() * 0.65 + (index - 1) * (buttonHeight + buttonSpacing)
end

function titlescreen.exit()
end

function titlescreen.update(dt)
   -- Scroll starfield to the left
   starfieldScroll = (starfieldScroll + dt * starfieldSpeed) % starfield:getWidth()
end

function titlescreen.mousepressed(x, y, button)
   for i, b in ipairs(buttons) do
      local bx = getButtonX()
      local by = getButtonY(i)
      if x >= bx and x <= bx + buttonWidth and y >= by and y <= by + buttonHeight then
         b.action()
         break
      end
   end
end

function titlescreen.draw()
   local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

   -- Background
   local imgW, imgH = starfield:getWidth(), starfield:getHeight()
	for y = 0, screenH, imgH do
	   for x = -imgW, screenW + imgW, imgW do
		  love.graphics.draw(starfield, x - starfieldScroll, y)
	   end
	end

   -- Title
   local titleText = "Bounds"
   local titleX = screenW / 2 - titleFont:getWidth(titleText) / 2
   local titleY = screenH * 0.2
   love.graphics.setFont(titleFont)
   love.graphics.setColor(0.6, 0.9, 1)
   love.graphics.print(titleText, titleX, titleY)

   -- Buttons
   local mx, my = love.mouse.getPosition()
   love.graphics.setFont(buttonFont)

   for i, b in ipairs(buttons) do
      local bx = getButtonX()
      local by = getButtonY(i)
      local isHovered = mx >= bx and mx <= bx + buttonWidth and my >= by and my <= by + buttonHeight

      love.graphics.setColor(1, 1, 1)
      nineslice.draw(uiBoxImage, bx, by, buttonWidth, buttonHeight)

      local textColor = isHovered and {1, 1, 0.8} or {0.8, 0.9, 1}
      love.graphics.setColor(textColor)
      love.graphics.printf(b.label, bx, by + 8, buttonWidth, "center")
   end

   love.graphics.setColor(1, 1, 1)
end

function titlescreen.keypressed(key)
   if key == "escape" then
      love.event.quit()
   end
end

return titlescreen