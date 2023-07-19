local level = require("level")
local collision = require("collision")
local explosion = require("explosion")

-- Define variables for player, spawn/end points
local player = {}
local spawnPoint = {}
local endPoint = {}
local gameWon = false  -- Flag to indicate if the player has won the game
local levelComplete = false  -- Flag to indicate if the level is complete
local startTime = 0  -- Variable to store the start time of the level
local levelCompleteTime = 0  -- Variable to store the start time of the level
local currentTime = 0  -- Variable to store the start time of the level

-- Define game constants
local MOVE_SPEED = 200
local TILE_SIZE = 32

-- Load tile images
local tileImages = {
   ["s"] = love.graphics.newImage("s.png"),
   ["e"] = love.graphics.newImage("e.png"),
   ["0"] = love.graphics.newImage("0.png"),
   ["1"] = love.graphics.newImage("1.png"),
   ["2"] = love.graphics.newImage("2.png"),
   ["3"] = love.graphics.newImage("3.png"),
   ["4"] = love.graphics.newImage("4.png"),
   ["5"] = love.graphics.newImage("5.png"),
   ["6"] = love.graphics.newImage("6.png"),
   ["7"] = love.graphics.newImage("7.png"),
   ["8"] = love.graphics.newImage("8.png"),
   ["9"] = love.graphics.newImage("9.png"),
}

local tileMap = {} -- Define the tile map with the appropriate tile types

function love.load()
   -- Set the window dimensions
   love.window.setMode(800, 600)

   -- Load the tile map from tilemap.csv
   tileMap = level.load()

   -- Initialize the player position, size, and velocity
   player.x = 0
   player.y = 0
   player.width = TILE_SIZE / 2
   player.height = TILE_SIZE / 2
   player.velocityX = 0
   player.velocityY = 0

   -- Iterate over the tile map to find the spawn point and end point
   for y = 1, #tileMap do
      for x = 1, #tileMap[y] do
         if tileMap[y][x] == "s" then
            spawnPoint.x = (x - 1) * TILE_SIZE
            spawnPoint.y = (y - 1) * TILE_SIZE
         elseif tileMap[y][x] == "e" then
            endPoint.x = (x - 1) * TILE_SIZE
            endPoint.y = (y - 1) * TILE_SIZE
         end
      end
   end

   -- Calculate the center position of the spawn platform
   local spawnX, spawnY

   for y = 1, #tileMap do
      for x = 1, #tileMap[y] do
         if tileMap[y][x] == "s" then
            spawnX = (x - 1) * TILE_SIZE
            spawnY = (y - 1) * TILE_SIZE
            break
         end
      end
      if spawnX and spawnY then
         break
      end
   end

   collision.calculateBounds(spawnPoint, endPoint)

   -- Set the player's initial position to be centered on the spawn platform
   player.x = spawnX + TILE_SIZE / 2 - player.width / 2
   player.y = spawnY + TILE_SIZE / 2 - player.height / 2

   startTime = love.timer.getTime()  -- Store the starting time
   
   -- Load the explosion sequences from the CSV file
   explosion.loadSequencesFromCSV("explosion1.csv")
end

function love.update(dt)
   -- Store the player's previous position
   local prevX = player.x
   local prevY = player.y

   -- Apply input to player's movement
   if love.keyboard.isDown("left") then
      player.velocityX = -MOVE_SPEED
   elseif love.keyboard.isDown("right") then
      player.velocityX = MOVE_SPEED
   else
      player.velocityX = 0
   end

   if love.keyboard.isDown("up") then
      player.velocityY = -MOVE_SPEED
   elseif love.keyboard.isDown("down") then
      player.velocityY = MOVE_SPEED
   else
      player.velocityY = 0
   end

   -- Calculate the player's potential new position
   local newX = player.x + player.velocityX * dt
   local newY = player.y + player.velocityY * dt

   -- Calculate the player's tile position
   local playerTileX = math.floor((newX + player.width / 2) / TILE_SIZE) + 1
   local playerTileY = math.floor((newY + player.height / 2) / TILE_SIZE) + 1

   -- Check if the player's potential new tile is void
   if tileMap[playerTileY][playerTileX] == "0" then
      -- Handle collision with void tile (stop player movement)
      if player.velocityX < 0 and tileMap[playerTileY][playerTileX+1] ~= "0" then
         -- Sliding along the left wall
         newX = player.x
      elseif player.velocityX > 0 and tileMap[playerTileY][playerTileX-1] ~= "0" then
         -- Sliding along the right wall
         newX = player.x
      elseif player.velocityY < 0 and tileMap[playerTileY+1][playerTileX] ~= "0" then
         -- Sliding along the top wall
         newY = player.y
      elseif player.velocityY > 0 and tileMap[playerTileY-1][playerTileX] ~= "0" then
         -- Sliding along the bottom wall
         newY = player.y
      else
         -- Stop player movement when not sliding along a wall
         newX = player.x
         newY = player.y
      end
   elseif tileMap[playerTileY][playerTileX] == "e" then
      -- Player reached the end point (finish platform)
      if not levelComplete then
         levelCompleteTime = currentTime
         levelComplete = true
         gameWon = true
         -- You can add level progression code here
      end
   end

   -- Update the player's position
   player.x = newX
   player.y = newY
end


function love.draw()
   -- This function runs every frame after update()
   -- Draw game objects and UI elements on the screen

   -- Draw the level based on the tile map
   for y = 1, #tileMap do
      for x = 1, #tileMap[y] do
         local tileType = tileMap[y][x]
         local tileImage = tileImages[tileType]
         love.graphics.draw(tileImage, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
      end
   end

   -- Draw explosions
   for i, explosion in ipairs(explosion.getCurrentExplosions()) do
      if explosion.active then
         love.graphics.setColor(explosion.r, explosion.g, explosion.b, 255)
         love.graphics.circle("fill", explosion.x, explosion.y, TILE_SIZE / 2)
      end
   end

   -- Draw game timer
   currentTime = love.timer.getTime() - startTime
   local timerText = string.format("%.2f", currentTime)
   local timerFont = love.graphics.newFont(20)
   love.graphics.setFont(timerFont)
   love.graphics.print(timerText, love.graphics.getWidth() / 2 - timerFont:getWidth(timerText) / 2, 20)

   -- Draw player
   love.graphics.setColor(255, 255, 255) -- Set color to white
   love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, player.width / 2)

   -- Check collision with explosions
   for i, explosion in ipairs(explosion.getCurrentExplosions()) do
      if explosion.active and collision.checkCollision(player, explosion) then
         -- Handle collision with explosion (e.g., player loses a life, reset level, etc.)
         resetLevel()
      end
   end

   -- Fade out explosions quickly
   for i, explosion in ipairs(explosion.getCurrentExplosions()) do
      if explosion.active then
         explosion.alpha = explosion.alpha - 500 * dt
         if explosion.alpha <= 0 then
            explosion.active = false
         end
      end
   end

   -- Draw end screen popup if the level is complete
   if levelComplete then
      local popupWidth = 400
      local popupHeight = 200
      local popupX = love.graphics.getWidth() / 2 - popupWidth / 2
      local popupY = love.graphics.getHeight() / 2 - popupHeight / 2

      love.graphics.setColor(0, 0, 0, 0.8)  -- Semi-transparent black background
      love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight)

      love.graphics.setColor(255, 255, 255)  -- White text color
      love.graphics.setFont(love.graphics.newFont(24))
      love.graphics.printf("Level Complete!", popupX, popupY + 30, popupWidth, "center")

      -- Draw level complete time
      local levelCompleteTimeText = string.format("Level Time: %.2f seconds", levelCompleteTime)
      love.graphics.setFont(love.graphics.newFont(18))
      love.graphics.printf(levelCompleteTimeText, popupX, popupY + 80, popupWidth, "center")

      local replayText = "Replay Level"
      local nextLevelText = "Next Level"
      local buttonText = replayText  -- Text on the button

      if gameWon then
         buttonText = nextLevelText
      end

      local buttonWidth = 160
      local buttonHeight = 40
      local replayButtonX = popupX + popupWidth / 2 - buttonWidth - 20
      local nextButtonX = popupX + popupWidth / 2 + 20
      local buttonY = popupY + popupHeight - 80

      -- Draw replay button
      love.graphics.setColor(255, 255, 255)  -- White button background
      love.graphics.rectangle("fill", replayButtonX, buttonY, buttonWidth, buttonHeight)

      love.graphics.setColor(0, 0, 0)  -- Black button text color
      love.graphics.setFont(love.graphics.newFont(18))
      love.graphics.printf(replayText, replayButtonX, buttonY + 10, buttonWidth, "center")

      -- Draw next level button
      love.graphics.setColor(255, 255, 255)  -- White button background
      love.graphics.rectangle("fill", nextButtonX, buttonY, buttonWidth, buttonHeight)

      love.graphics.setColor(0, 0, 0)  -- Black button text color
      love.graphics.setFont(love.graphics.newFont(18))
      love.graphics.printf(nextLevelText, nextButtonX, buttonY + 10, buttonWidth, "center")
   end
end

function resetLevel()
	tileMap = level.load()

   -- Calculate the center position of the spawn platform
   local spawnX, spawnY

   for y = 1, #tileMap do
      for x = 1, #tileMap[y] do
         if tileMap[y][x] == "s" then
            spawnX = (x - 1) * TILE_SIZE
            spawnY = (y - 1) * TILE_SIZE
            break
         end
      end
      if spawnX and spawnY then
         break
      end
   end

   -- Set the player's initial position to be centered on the spawn platform
   player.x = spawnX + TILE_SIZE / 2 - player.width / 2
   player.y = spawnY + TILE_SIZE / 2 - player.height / 2

   collision.calculateBounds(spawnPoint, endPoint)

   levelComplete = false
   startTime = love.timer.getTime()  -- Reset the starting time
end

function love.mousepressed(x, y, button)
   if levelComplete then
      local popupWidth = 400
      local popupHeight = 200
      local popupX = love.graphics.getWidth() / 2 - popupWidth / 2
      local popupY = love.graphics.getHeight() / 2 - popupHeight / 2

      local buttonWidth = 160
      local buttonHeight = 40
      local replayButtonX = popupX + popupWidth / 2 - buttonWidth - 20
      local nextButtonX = popupX + popupWidth / 2 + 20
      local buttonY = popupY + popupHeight - 80

      -- Check if replay button is clicked
      if x >= replayButtonX and x <= replayButtonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
         -- Reset level
         resetLevel()
      end

		-- Check if next level button is clicked
		if gameWon and x >= nextButtonX and x <= nextButtonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
		   -- Proceed to next level
		   level.nextLevel()
		   resetLevel()  -- Reset the level and load the new map
		end
   end
end

function love.keypressed(key)
   if key == "r" then
      -- Reset the level when "r" key is pressed
      level.reset()
      love.load()
   end
end