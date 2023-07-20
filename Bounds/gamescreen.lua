local gamescreen = {}

local ui = require("ui")
local level = require("level")
local collision = require("collision")
local gamestate = require("gamestate")
local triggers = require("triggers1")

-- Define variables and constants specific to the game screen
local player = {}
local spawnPoint = {}
local endPoint = {}
local tileMap = {}
local explosions = {}
local gameWon = false
local levelComplete = false
local startTime = 0
local levelCompleteTime = 0
local currentTime = 0

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

-- Implement the love.load() function for initializing the game screen
function gamescreen.enter()
   -- Set the window dimensions
   love.window.setMode(800, 600)
   love.window.setTitle("Blast Runner")

   -- Load the tile map from the level module
   tileMap = level.load()

   -- Find the spawn point and end point on the tile map
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

   -- Initialize the player position, size, and velocity
   player.width = TILE_SIZE / 2
   player.height = TILE_SIZE / 2
   player.velocityX = 0
   player.velocityY = 0
   player.x = spawnX + TILE_SIZE / 2 - player.width / 2
   player.y = spawnY + TILE_SIZE / 2 - player.height / 2

   -- Initialize other game state-specific variables and objects
   -- (e.g., explosions, timers, etc.)

   -- Initialize the UI for the level (if applicable)
   ui.initLevel(1)

   -- Clear existing explosions
   explosions = {}

   -- Create explosions based on the trigger data
   for _, triggerData in ipairs(triggers) do
      if type(triggerData[1]) == "table" then
         for _, nestedTriggerData in ipairs(triggerData) do -- Handle nested trigger data
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
         local explosion = { -- Handle single trigger data
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

function gamescreen.exit()

end

-- Implement the love.update() function for updating game state-specific logic
function gamescreen.update(dt)
   -- Update the current game state-specific logic

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

   -- Apply input to player's movement
   local newX = player.x + player.velocityX * dt
   local newY = player.y + player.velocityY * dt

   -- Calculate the player's tile position
   local playerTileX = math.floor((newX + player.width / 2) / TILE_SIZE) + 1
   local playerTileY = math.floor((newY + player.height / 2) / TILE_SIZE) + 1

   -- Check collision with void tiles ("0")
   if tileMap[playerTileY][playerTileX] == "0" then
      -- Handle collision with void tile (stop player movement)
      if player.velocityX < 0 and tileMap[playerTileY][playerTileX + 1] ~= "0" then
         newX = player.x  -- Sliding along the left wall
      elseif player.velocityX > 0 and tileMap[playerTileY][playerTileX - 1] ~= "0" then
         newX = player.x  -- Sliding along the right wall
      elseif player.velocityY < 0 and tileMap[playerTileY + 1][playerTileX] ~= "0" then
         newY = player.y  -- Sliding along the top wall
      elseif player.velocityY > 0 and tileMap[playerTileY - 1][playerTileX] ~= "0" then
         newY = player.y  -- Sliding along the bottom wall
      else
         newX = player.x  -- Stop player movement when not sliding along a wall
         newY = player.y
      end
   end

   -- Check if the player has won the game (optional, based on your game rules)
   if tileMap[playerTileY][playerTileX] == "e" then
      -- Player reached the end point (finish platform)
      if not levelComplete then
         levelCompleteTime = currentTime
         levelComplete = true
         gameWon = true
         ui.setLevelCompleteTime(currentTime)  -- Set the level complete time in the UI
         -- Additional logic for advancing to the next level if needed
      end
	  
		if levelComplete then
		   gamestate.setState("endscreen")
		end
   end

   -- Update the player's position
   player.x = newX
   player.y = newY

   -- Update explosions and other game state-specific updates

   -- Update the UI for the level (if applicable)
   currentTime = ui.updateTimer() -- Remove the local declaration of currentTime here
end

-- Implement the love.draw() function for rendering game state-specific graphics
function gamescreen.draw()
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
end

-- Implement the love.mousepressed() function for handling mouse click events
function gamescreen.mousepressed(x, y, button)
   -- Implement the game state-specific mouse click handling logic, if needed.
end

-- Implement the love.keypressed() function for handling key press events
function gamescreen.keypressed(key)
   -- Implement the game state-specific key press handling logic, if needed.
end

return gamescreen