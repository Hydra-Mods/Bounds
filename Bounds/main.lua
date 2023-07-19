local ui = require("ui")
local level = require("level")
local collision = require("collision")
local triggers = require("triggers1")

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
local explosions = {}
local currentExplosionIndex = 1  -- Index of the current explosion

function love.load()
   -- Set the window dimensions
   love.window.setMode(800, 600)
   love.window.setTitle("Blast Runner")

   -- Initialize the player position, size, and velocity
   player.x = 0
   player.y = 0
   player.width = TILE_SIZE / 2
   player.height = TILE_SIZE / 2
   player.velocityX = 0
   player.velocityY = 0

	tileMap = level.load()

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

	ui.initLevel(1)

   -- Clear existing explosions
   explosions = {}

   -- Create explosions based on the trigger data
   for _, triggerData in ipairs(triggers) do
      if type(triggerData[1]) == "table" then
         -- Handle nested trigger data
         for _, nestedTriggerData in ipairs(triggerData) do
            local explosion = {
               x = nestedTriggerData[1],
               y = nestedTriggerData[2],
               active = false,
               timer = 0,
               delay = nestedTriggerData[3],
               duration = 1,
               color = {r = nestedTriggerData[4], g = nestedTriggerData[5], b = nestedTriggerData[6]}
            }
            table.insert(explosions, explosion)
         end
      else
         -- Handle single trigger data
         local explosion = {
            x = triggerData[1],
            y = triggerData[2],
            active = false,
            timer = 0,
            delay = triggerData[3],
            duration = 1,
            color = {r = triggerData[4], g = triggerData[5], b = triggerData[6]}
         }
         table.insert(explosions, explosion)
      end
   end
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
         ui.setLevelCompleteTime(currentTime)  -- Set the level complete time in the UI
         -- Additional logic for advancing to the next level
      end
   end

   -- Update the player's position
   player.x = newX
   player.y = newY

	local currentTime = ui.updateTimer()

   -- Update explosions
   for _, triggerData in ipairs(triggers) do
      local activeExplosions = {}  -- Keep track of active explosions for each trigger index

      for _, explosionData in ipairs(triggerData) do
         local explosion = {
            x = explosionData[1],
            y = explosionData[2],
            active = false,
            timer = 0,
            delay = explosionData[3],
            duration = 0.3,
            color = {r = explosionData[4], g = explosionData[5], b = explosionData[6]}
         }

         if not explosion.active and explosion.timer >= explosion.delay then
            -- Activate the explosion
            explosion.active = true
            table.insert(activeExplosions, explosion)  -- Add the active explosion to the list
         end

         if explosion.active and explosion.timer >= explosion.duration then
            -- Deactivate the explosion
            explosion.active = false
            explosion.timer = 0  -- Reset the timer for the next activation
         end

         explosion.timer = explosion.timer + dt  -- Update the timer for the explosion
      end

      -- Update the explosions list with the active explosions
      for _, activeExplosion in ipairs(activeExplosions) do
         table.insert(explosions, activeExplosion)
      end
   end
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

	love.graphics.setColor(255, 255, 255)

   -- Draw explosions
   for _, explosion in ipairs(explosions) do
      if explosion.active then
         local explosionX = (explosion.x - 1) * TILE_SIZE + TILE_SIZE / 2
         local explosionY = (explosion.y - 1) * TILE_SIZE + TILE_SIZE / 2

         love.graphics.setColor(explosion.color.r, explosion.color.g, explosion.color.b)
         love.graphics.circle("fill", explosionX, explosionY, TILE_SIZE / 2)
      end
   end

   -- Reset color to white before drawing the timer
   love.graphics.setColor(255, 255, 255)

	ui.drawTimer()

ui.drawLevelIndicator()

   -- Draw player
   love.graphics.setColor(255, 255, 255) -- Set color to white
   love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, player.width / 2)

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
  -- Load the tile map from tilemap.csv
  tileMap = level.load()

  -- Clear existing explosions
  explosions = {}

  -- Create explosions based on the explosionSequence data
  for _, explosionData in ipairs(explosionSequence) do
    local explosion = {
      x = explosionData.x,
      y = explosionData.y,
      active = false,
      timer = 0,
      delay = explosionData.delay,
      duration = explosionData.duration,
    }
    table.insert(explosions, explosion)
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

  -- Set the player's initial position to be centered on the spawn platform
  player.x = spawnX + TILE_SIZE / 2 - player.width / 2
  player.y = spawnY + TILE_SIZE / 2 - player.height / 2

  collision.calculateBounds(spawnPoint, endPoint)

  levelComplete = false
  startTime = love.timer.getTime() -- Reset the starting time
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