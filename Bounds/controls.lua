local controls = {}

local player = require("player")

local MOVE_SPEED = 200
local DEADZONE = 0.0001

-- Get the first connected gamepad
local function getGamepad()
   local joysticks = love.joystick.getJoysticks()
   for _, js in ipairs(joysticks) do
      if js:isGamepad() then
         return js
      end
   end
   return nil
end

function controls.handleInput()
   local velocityX, velocityY = 0, 0
   local gamepad = getGamepad()

   -- === Keyboard Input ===
   if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      velocityX = velocityX - MOVE_SPEED
   end
   if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      velocityX = velocityX + MOVE_SPEED
   end
   if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      velocityY = velocityY - MOVE_SPEED
   end
   if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      velocityY = velocityY + MOVE_SPEED
   end

   -- === Gamepad Input ===
   if gamepad then
      -- Analog stick
      local lx = gamepad:getGamepadAxis("leftx")
      local ly = gamepad:getGamepadAxis("lefty")

      if math.abs(lx) > DEADZONE then
         velocityX = velocityX + lx * MOVE_SPEED
      end
      if math.abs(ly) > DEADZONE then
         velocityY = velocityY + ly * MOVE_SPEED
      end

      -- D-Pad fallback (digital)
      if gamepad:isGamepadDown("dpleft") then
         velocityX = velocityX - MOVE_SPEED
      end
      if gamepad:isGamepadDown("dpright") then
         velocityX = velocityX + MOVE_SPEED
      end
      if gamepad:isGamepadDown("dpup") then
         velocityY = velocityY - MOVE_SPEED
      end
      if gamepad:isGamepadDown("dpdown") then
         velocityY = velocityY + MOVE_SPEED
      end
   end

   player.setVelocity(velocityX, velocityY)
end

return controls