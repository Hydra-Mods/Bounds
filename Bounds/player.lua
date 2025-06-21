local player = {}

local TILE_SIZE = 32
local MOVE_SPEED = 200

function player.initialize(x, y, size)
   player.width = size
   player.height = size
   player.x = x
   player.y = y
   player.velocityX = 0
   player.velocityY = 0
end

function player.setVelocity(velocityX, velocityY)
   player.velocityX = velocityX
   player.velocityY = velocityY
end

function player.getVelocity()
   return player.velocityX, player.velocityY
end

function player.draw()
   local playerX, playerY = player.getPosition()
   love.graphics.setColor(255, 255, 255)
   love.graphics.circle("fill", playerX + player.width / 2, playerY + player.height / 2, player.width / 2)
end

-- Removed the call to collision module
function player.update(dt)
   -- No logic here anymore, handled externally
end

function player.setPosition(x, y)
   player.x = x
   player.y = y
end

function player.getPosition()
   return player.x, player.y
end

return player