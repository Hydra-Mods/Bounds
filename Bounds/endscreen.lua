local endscreen = {}

local ui = require("ui")
local gamestate = require("gamestate")

local nextLevelAvailable = false

-- Track mouse interaction
local mouseX, mouseY = 0, 0

-- Button constants
local buttonWidth = 200
local buttonHeight = 40
local buttonX = 300
local nextY = 280
local function replayY() return nextLevelAvailable and 340 or 280 end

function endscreen.enter(canProceed)
   nextLevelAvailable = canProceed
end

function endscreen.exit()
   -- Reset UI for next level
   ui.resetRespawns()
   ui.resetTimer()
end

function endscreen.update(dt)
   mouseX, mouseY = love.mouse.getPosition()
end

function endscreen.mousepressed(x, y, button)
   if nextLevelAvailable and
      x >= buttonX and x <= buttonX + buttonWidth and
      y >= nextY and y <= nextY + buttonHeight then
         endscreen.exit()
         gamestate.setState("gamescreen", true) -- Proceed to next level
   end

   if x >= buttonX and x <= buttonX + buttonWidth and
      y >= replayY() and y <= replayY() + buttonHeight then
         endscreen.exit()
         gamestate.setState("gamescreen", false) -- Replay same level (or just reset player state)
   end
end

function endscreen.keypressed(key)
   if nextLevelAvailable then
      endscreen.exit()
      gamestate.setState("gamescreen", true)
   end
end

function endscreen.draw()
   love.graphics.setColor(0, 0, 0, 0.8)
   love.graphics.rectangle("fill", 200, 150, 400, 340)

   love.graphics.setColor(255, 255, 255)
   love.graphics.setFont(love.graphics.newFont(24))
   love.graphics.printf("Level Complete!", 200, 180, 400, "center")

   local levelCompleteTime = ui.getLevelCompleteTime()
   love.graphics.setFont(love.graphics.newFont(18))
   love.graphics.printf(string.format("Level Time: %.2f seconds", levelCompleteTime), 200, 220, 400, "center")

   local respawns = ui.getRespawnCount()
   love.graphics.printf("Respawns: " .. respawns, 200, 250, 400, "center")

   local function drawButton(label, x, y)
      local isHovered = mouseX >= x and mouseX <= x + buttonWidth and mouseY >= y and mouseY <= y + buttonHeight
      local isClicked = love.mouse.isDown(1) and isHovered

      local scale = isHovered and (isClicked and 0.95 or 1.05) or 1.0
      local color = isHovered and {150, 150, 150} or {100, 100, 100}

      love.graphics.setColor(color)
      love.graphics.push()
      love.graphics.translate(x + buttonWidth / 2, y + buttonHeight / 2)
      love.graphics.scale(scale, scale)
      love.graphics.rectangle("fill", -buttonWidth / 2, -buttonHeight / 2, buttonWidth, buttonHeight)
      love.graphics.pop()

      love.graphics.setColor(0, 0, 0)
      local font = love.graphics.getFont()
      local textX = x + buttonWidth / 2 - font:getWidth(label) / 2
      local textY = y + buttonHeight / 2 - font:getHeight() / 2
      love.graphics.print(label, textX, textY)
   end

   if nextLevelAvailable then
      drawButton("Next Level", buttonX, nextY)
   end

   drawButton("Replay Level", buttonX, replayY())
end

return endscreen