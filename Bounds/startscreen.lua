local startscreen = {}
local gamestate = require("gamestate")

-- Define quitButtonX before the startscreen.draw() function
local quitButtonX = love.graphics.getWidth() / 2 - 50

function startscreen.enter()
   -- Your start screen initialization code here, if needed.
end

function startscreen.exit()
   -- Your start screen cleanup code here, if needed.
end

function startscreen.update(dt)
   -- Your start screen update code here, if needed.
end

function startscreen.mousepressed(x, y, button)
   -- Check if the mouse click was inside the play button area
   local buttonX = love.graphics.getWidth() / 2 - 50
   local buttonY = love.graphics.getHeight() * 3 / 4
   local buttonWidth = 100
   local buttonHeight = 40

   if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
      -- Start the game by setting the current game state to "gamescreen"
      gamestate.setState("gamescreen")
   end

   -- Check if the mouse click was inside the quit button area
   local quitButtonY = love.graphics.getHeight() * 3 / 4 + 60 -- Add some vertical space between buttons
   local quitButtonWidth = 100
   local quitButtonHeight = 40

   if x >= quitButtonX and x <= quitButtonX + quitButtonWidth and y >= quitButtonY and y <= quitButtonY + quitButtonHeight then
      -- Quit the game when the quit button is clicked
      love.event.quit()
   end
end

function startscreen.keypressed(key)
   -- Your start screen key press handling code here, if needed.
end

function startscreen.draw()
   -- Clear the screen
   love.graphics.clear(0, 0, 0)

   -- Draw the title text with a shadow effect and an earthy orange color
   local titleFont = love.graphics.newFont(96)
   love.graphics.setFont(titleFont)
   local titleText = "Blast Runner"
   local titleWidth = titleFont:getWidth(titleText)
   local titleX = love.graphics.getWidth() / 2 - titleWidth / 2
   local titleY = love.graphics.getHeight() / 4 - titleFont:getHeight() / 2
   local shadowOffset = 4
   love.graphics.setColor(0, 0, 0)
   love.graphics.print(titleText, titleX, titleY + shadowOffset)
   love.graphics.setColor(242, 144, 45)
   love.graphics.print(titleText, titleX, titleY)

   -- Draw the play button with a hover and click effect
   local buttonFont = love.graphics.newFont(20)
   love.graphics.setFont(buttonFont)
   local buttonX = love.graphics.getWidth() / 2 - 50
   local buttonY = love.graphics.getHeight() * 3 / 4
   local buttonWidth = 100
   local buttonHeight = 40
   local mouseX, mouseY = love.mouse.getPosition()
   local buttonColor = { 100, 100, 100 }
   local buttonScale = 1.0

   -- Check if the mouse is over the button
   local isMouseOverButton = mouseX >= buttonX and mouseX <= buttonX + buttonWidth and mouseY >= buttonY and mouseY <= buttonY + buttonHeight
   if isMouseOverButton then
      buttonColor = { 150, 150, 150 }
      buttonScale = 1.05 -- Slightly increase button size
   end

   -- Check if the button is clicked
   local isButtonClicked = love.mouse.isDown(1) and isMouseOverButton
   if isButtonClicked then
      buttonX = buttonX + 2
      buttonY = buttonY + 2
      buttonScale = 0.95 -- Slightly decrease button size
   end

   love.graphics.setColor(buttonColor)
   love.graphics.push()
   love.graphics.translate(buttonX + buttonWidth / 2, buttonY + buttonHeight / 2)
   love.graphics.scale(buttonScale, buttonScale)
   love.graphics.rectangle("fill", -buttonWidth / 2, -buttonHeight / 2, buttonWidth, buttonHeight)
   love.graphics.pop()

   love.graphics.setColor(0, 0, 0)
   local buttonText = "Play"
   local textX = buttonX + buttonWidth / 2 - buttonFont:getWidth(buttonText) / 2
   local textY = buttonY + buttonHeight / 2 - buttonFont:getHeight() / 2
   love.graphics.print(buttonText, textX, textY)

   -- Draw the quit button with a hover and click effect
   local quitButtonY = love.graphics.getHeight() * 3 / 4 + 60 -- Add some vertical space between buttons
   local quitButtonColor = { 100, 100, 100 }
   local quitButtonScale = 1.0

   -- Check if the mouse is over the quit button
   local isMouseOverQuitButton = mouseX >= quitButtonX and mouseX <= quitButtonX + buttonWidth and mouseY >= quitButtonY and mouseY <= quitButtonY + buttonHeight
   if isMouseOverQuitButton then
      quitButtonColor = { 150, 150, 150 }
      quitButtonScale = 1.05 -- Slightly increase button size
   end

   -- Check if the quit button is clicked
   local isQuitButtonClicked = love.mouse.isDown(1) and isMouseOverQuitButton
   if isQuitButtonClicked then
      quitButtonX = quitButtonX + 2
      quitButtonY = quitButtonY + 2
      quitButtonScale = 0.95 -- Slightly decrease button size
   end

   love.graphics.setColor(quitButtonColor)
   love.graphics.push()
   love.graphics.translate(quitButtonX + buttonWidth / 2, quitButtonY + buttonHeight / 2)
   love.graphics.scale(quitButtonScale, quitButtonScale)
   love.graphics.rectangle("fill", -buttonWidth / 2, -buttonHeight / 2, buttonWidth, buttonHeight)
   love.graphics.pop()

   love.graphics.setColor(0, 0, 0)
   local quitButtonText = "Quit"
   local quitTextX = quitButtonX + buttonWidth / 2 - buttonFont:getWidth(quitButtonText) / 2
   local quitTextY = quitButtonY + buttonHeight / 2 - buttonFont:getHeight() / 2
   love.graphics.print(quitButtonText, quitTextX, quitTextY)
end

return startscreen
