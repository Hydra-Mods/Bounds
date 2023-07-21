local gamescreen = {}

local ui = require("ui")
local level = require("level")
local collision = require("collision")
local explosions = require("explosions")
local gamestate = require("gamestate")
local triggers = require("triggers1")
local player = require("player")
local controls = require("controls")
local tilemap = require("tilemap")

-- Define variables and constants specific to the game screen
local spawnPoint = {}
local endPoint = {}
local currentTileMap = {}
local gameWon = false
local levelComplete = false
local startTime = 0
local levelCompleteTime = 0
local currentTime = 0

local TILE_SIZE = 32

function gamescreen.enter()
   currentTileMap = level.load() -- Load the tile map from the level module

   -- Find the spawn point and end point on the tile map
   for y = 1, #currentTileMap do
      for x = 1, #currentTileMap[y] do
         if currentTileMap[y][x] == "s" then
            spawnPoint.x = (x - 1) * TILE_SIZE
            spawnPoint.y = (y - 1) * TILE_SIZE
         elseif currentTileMap[y][x] == "e" then
            endPoint.x = (x - 1) * TILE_SIZE
            endPoint.y = (y - 1) * TILE_SIZE
         end
      end
   end

   local spawnX, spawnY -- Calculate the center position of the spawn platform

   for y = 1, #currentTileMap do
      for x = 1, #currentTileMap[y] do
         if currentTileMap[y][x] == "s" then
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

	player.initialize(spawnX, spawnY, TILE_SIZE)

   ui.initLevel(1) -- Initialize the UI for the level (if applicable)

	explosions.initialize(triggers) -- Initialize explosions
end

function gamescreen.exit()

end

local PLAYER_COLLISION_THRESHOLD = 16 -- Adjust this value as needed for better collision detection

function gamescreen.update(dt) -- Update the current game state-specific logic
   controls.handleInput() -- Handle player controls

   -- Update player movement
   player.update(dt)

   -- Check for finish platform collision
   local playerX, playerY = player.getPosition()
   if collision.checkFinishPlatformCollision(playerX, playerY) then
      -- Player has reached the finish platform, set game state to "endscreen"
      gamestate.setState("endscreen")
   end

   -- Check for collision with void tiles
   local tileX = math.floor(playerX / TILE_SIZE) + 1
   local tileY = math.floor(playerY / TILE_SIZE) + 1
   if currentTileMap[tileY][tileX] == "0" then
      -- Player collided with a void tile, respawn the player at the spawn point
      player.setPosition(spawnPoint.x, spawnPoint.y)
   end

   -- Check for collision with active explosions
   for _, explosionGroup in ipairs(explosions.list) do
      for _, explosion in ipairs(explosionGroup) do
         if explosion.active then
            local explosionX = (explosion.x - 1) * TILE_SIZE + TILE_SIZE / 2
            local explosionY = (explosion.y - 1) * TILE_SIZE + TILE_SIZE / 2

            -- Calculate the distance between the player and the explosion center
            local distance = math.sqrt((playerX - explosionX) ^ 2 + (playerY - explosionY) ^ 2)

            -- If the player is close enough to an active explosion, respawn the player at the spawn point
            if distance < PLAYER_COLLISION_THRESHOLD then
               player.setPosition(spawnPoint.x, spawnPoint.y)
            end
         end
      end
   end

   explosions.update(dt) -- Update explosions

   -- Update the UI for the level (if applicable)
   currentTime = ui.updateTimer()
end

function gamescreen.draw() -- Implement the love.draw() function for rendering game state-specific graphics
	tilemap.draw(currentTileMap) -- Draw the level based on the tile map

   love.graphics.setColor(255, 255, 255)

   explosions.draw() -- Draw explosions

   love.graphics.setColor(255, 255, 255) -- Reset color to white before drawing the timer

   ui.drawTimer()

   ui.drawLevelIndicator()

	player.draw()
end

function gamescreen.mousepressed(x, y, button)
   -- Implement the game state-specific mouse click handling logic, if needed.
end

function gamescreen.keypressed(key)
   -- Implement the game state-specific key press handling logic, if needed.
end

return gamescreen