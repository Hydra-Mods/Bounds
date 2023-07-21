local controls = {}

local player = require("player")

local MOVE_SPEED = 200

function controls.handleInput()
   -- Apply input to player's movement
   local velocityX, velocityY = 0, 0

   if love.keyboard.isDown("left") then
      velocityX = -MOVE_SPEED
   elseif love.keyboard.isDown("right") then
      velocityX = MOVE_SPEED
   end

   if love.keyboard.isDown("up") then
      velocityY = -MOVE_SPEED
   elseif love.keyboard.isDown("down") then
      velocityY = MOVE_SPEED
   end

   player.setVelocity(velocityX, velocityY)
end

return controls