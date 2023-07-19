local ui = {}

local currentLevel = 1
local startTime = 0
local levelCompleteTime = 0

function ui.initLevel(level)
   currentLevel = level
   startTime = love.timer.getTime()
   levelCompleteTime = 0
end

function ui.updateTimer()
   -- Calculate the current game time
   local currentTime = love.timer.getTime() - startTime

   -- Return the formatted time string
   return string.format("%.2f", currentTime)
end

function ui.getLevelCompleteTime()
   return levelCompleteTime
end

function ui.setLevelCompleteTime(time)
   levelCompleteTime = time
end

function ui.getCurrentLevel()
   return currentLevel
end

function ui.setCurrentLevel(level)
   currentLevel = level
end

function ui.drawTimer()
   local timerText = ui.updateTimer()
   local timerFont = love.graphics.newFont(20)

   love.graphics.setFont(timerFont)
   love.graphics.print(timerText, love.graphics.getWidth() / 2 - timerFont:getWidth(timerText) / 2, 20)
end

function ui.drawLevelIndicator()
   love.graphics.setColor(255, 255, 255)
   love.graphics.setFont(love.graphics.newFont(18))
   love.graphics.print("Level: " .. currentLevel, 20, 20)
end

return ui