local collision = {}

local spawnBounds = {}
local endBounds = {}

local TILE_SIZE = 32

function collision.calculateBounds(spawnPoint, endPoint)
   -- Calculate the boundaries of the spawn point and end point
   spawnBounds.left = spawnPoint.x
   spawnBounds.top = spawnPoint.y
   spawnBounds.right = spawnPoint.x + TILE_SIZE
   spawnBounds.bottom = spawnPoint.y + TILE_SIZE

   endBounds.left = endPoint.x
   endBounds.top = endPoint.y
   endBounds.right = endPoint.x + TILE_SIZE
   endBounds.bottom = endPoint.y + TILE_SIZE
end

function collision.checkPlayerCollision(player, tileMap, tileX, tileY)
   -- Check if the player collides with any solid tiles
   if tileMap[tileY][tileX] == "0" then
      return true
   end

   -- Calculate the player's bounding box coordinates
   local playerLeft = player.x
   local playerRight = player.x + player.width
   local playerTop = player.y
   local playerBottom = player.y + player.height

   -- Calculate the tile coordinates of the player's edges
   local leftTileX = math.floor(playerLeft / TILE_SIZE) + 1
   local rightTileX = math.floor(playerRight / TILE_SIZE) + 1
   local topTileY = math.floor(playerTop / TILE_SIZE) + 1
   local bottomTileY = math.floor(playerBottom / TILE_SIZE) + 1

   -- Check which edges are colliding with void tiles
   local collideLeft = tileMap[topTileY][leftTileX] == "0" or tileMap[bottomTileY][leftTileX] == "0"
   local collideRight = tileMap[topTileY][rightTileX] == "0" or tileMap[bottomTileY][rightTileX] == "0"
   local collideTop = tileMap[topTileY][leftTileX] == "0" or tileMap[topTileY][rightTileX] == "0"
   local collideBottom = tileMap[bottomTileY][leftTileX] == "0" or tileMap[bottomTileY][rightTileX] == "0"

   -- Adjust player's position based on collision direction
   if collideLeft and not collideRight then
      player.x = (leftTileX * TILE_SIZE) + 1
   elseif collideRight and not collideLeft then
      player.x = (rightTileX - 1) * TILE_SIZE - player.width - 1
   end

   if collideTop and not collideBottom then
      player.y = (topTileY * TILE_SIZE) + 1
   elseif collideBottom and not collideTop then
      player.y = (bottomTileY - 1) * TILE_SIZE - player.height - 1
   end

   return false
end

function collision.checkPlayerBounds(player, tileMap, tileX, tileY, tileType)
   -- Check if the player's position intersects with a tile of the specified type

   if tileMap[tileY] and tileMap[tileY][tileX] then
      local tile = tileMap[tileY][tileX]
      return tile == tileType
   end

   return false
end

return collision