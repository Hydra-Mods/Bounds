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

function gamescreen.update(dt) -- Update the current game state-specific logic
   controls.handleInput() -- Handle player controls

   -- Calculate the player's tile position (Collision detection)
   local playerTileX = math.floor((player.x + player.width / 2) / TILE_SIZE) + 1
   local playerTileY = math.floor((player.y + player.height / 2) / TILE_SIZE) + 1

   -- Check collision with void tiles ("0")
   if collision.checkPlayerCollision(player, currentTileMap, playerTileX, playerTileY) then
      -- Handle collision with void tile (stop player movement)
      if player.velocityX < 0 and currentTileMap[playerTileY][playerTileX + 1] ~= "0" then
         player.x = prevX  -- Sliding along the left wall
      elseif player.velocityX > 0 and currentTileMap[playerTileY][playerTileX - 1] ~= "0" then
         player.x = prevX  -- Sliding along the right wall
      elseif player.velocityY < 0 and currentTileMap[playerTileY + 1][playerTileX] ~= "0" then
         player.y = prevY  -- Sliding along the top wall
      elseif player.velocityY > 0 and currentTileMap[playerTileY - 1][playerTileX] ~= "0" then
         player.y = prevY  -- Sliding along the bottom wall
      end
   else
      -- Update player position based on velocity (move player if there's no collision)
      player.x = player.x + player.velocityX * dt
      player.y = player.y + player.velocityY * dt
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