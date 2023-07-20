local endscreen = {}

local ui = require("ui")

local nextLevelAvailable = false

function endscreen.enter(canProceed)
   nextLevelAvailable = canProceed
end

function endscreen.exit()
   -- Reset end screen-specific variables here
end

function endscreen.update(dt)
   -- Update end screen-specific logic here
end

function endscreen.mousepressed(x, y, button)
   -- Handle mouse click events on the end screen

   -- Check if "Replay Level" button is clicked
   if x >= 300 and x <= 500 and y >= 250 and y <= 290 then
      endscreen.exit()
      love.event.quit("restart") -- Restart the game to replay the level
   end

   -- Check if "Next Level" button is clicked
   if nextLevelAvailable and x >= 300 and x <= 500 and y >= 310 and y <= 350 then
      endscreen.exit()
      love.event.quit("next") -- Move on to the next level
   end
end

function endscreen.keypressed(key)
   -- Handle key press events on the end screen

   -- Pressing any key will have the same effect as clicking the "Next Level" button
   if nextLevelAvailable then
      endscreen.exit()
      love.event.quit("next") -- Move on to the next level
   end
end

function endscreen.draw()
   -- Draw the end screen UI elements

   love.graphics.setColor(0, 0, 0, 0.8)  -- Semi-transparent black background
   love.graphics.rectangle("fill", 200, 150, 400, 250)

   love.graphics.setColor(255, 255, 255)  -- White text color
   love.graphics.setFont(love.graphics.newFont(24))
   love.graphics.printf("Level Complete!", 200, 180, 400, "center")

   -- Get level complete time from the ui module
   local levelCompleteTime = ui.getLevelCompleteTime()

   local levelCompleteTimeText = string.format("Level Time: %.2f seconds", levelCompleteTime)
   love.graphics.setFont(love.graphics.newFont(18))
   love.graphics.printf(levelCompleteTimeText, 200, 220, 400, "center")

   local replayText = "Replay Level"
   local nextLevelText = "Next Level"
   local buttonText = replayText  -- Text on the button
   local buttonY = 250  -- Y-coordinate for button positioning

   if nextLevelAvailable then
      buttonText = nextLevelText
      buttonY = 310
   end

   local buttonWidth = 200
   local buttonHeight = 40

   -- Draw replay/next level button
   love.graphics.setColor(255, 255, 255)  -- White button background
   love.graphics.rectangle("fill", 300, buttonY, buttonWidth, buttonHeight)

   love.graphics.setColor(0, 0, 0)  -- Black button text color
   love.graphics.setFont(love.graphics.newFont(18))
   love.graphics.printf(buttonText, 300, buttonY + 10, buttonWidth, "center")
end

return endscreen
