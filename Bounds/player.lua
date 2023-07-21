local player = {}

local MOVE_SPEED = 200

function player.initialize(spawnX, spawnY, tileSize)
   player.width = tileSize / 2
   player.height = tileSize / 2
   player.velocityX = 0
   player.velocityY = 0
   player.x = spawnX + tileSize / 2 - player.width / 2
   player.y = spawnY + tileSize / 2 - player.height / 2
end

function player.setVelocity(velocityX, velocityY)
   player.velocityX = velocityX
   player.velocityY = velocityY
end

function player.draw()
   local playerX, playerY = player.getPosition()
   love.graphics.setColor(255, 255, 255) -- Set color to white
   love.graphics.circle("fill", playerX + player.width / 2, playerY + player.height / 2, player.width / 2)
end

function player.update(dt)
   -- Update player's position based on velocity and delta time (dt)
   player.x = player.x + player.velocityX * dt
   player.y = player.y + player.velocityY * dt
end

function player.setPosition(x, y)
   player.x = x
   player.y = y
end

function player.getPosition()
   return player.x, player.y
end

return player