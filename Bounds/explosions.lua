local explosions = {}

local TILE_SIZE = 32
local currentIndex = 1
local explosionDelay = 1 -- Adjust the delay as needed (in seconds)
local explosionTimer = explosionDelay

local function createExplosion(x, y, r, g, b)
   return {
      x = x,
      y = y,
      active = false,
      r = r,
      g = g,
      b = b,
   }
end

function explosions.initialize(triggers)
   explosions.list = {}

   -- Create explosions based on the trigger data
   for _, indexTriggers in ipairs(triggers) do
      local explosionGroup = {}
      for _, triggerData in ipairs(indexTriggers) do
         table.insert(explosionGroup, createExplosion(triggerData[1], triggerData[2], triggerData[3], triggerData[4], triggerData[5]))
      end
      table.insert(explosions.list, explosionGroup)
   end

   -- Store triggers data in the explosions table
   explosions.currentTriggers = triggers
   
   if triggers.Delay and type(triggers.Delay) == "number" then
      explosionDelay = triggers.Delay
	  explosionTimer = explosionDelay
   end
end

function explosions.update(dt)
   explosionTimer = explosionTimer - dt

   if explosionTimer <= 0 then
      -- Update all active explosions in the current index
      for _, explosion in ipairs(explosions.list[currentIndex]) do
         if explosion.active then
            explosion.active = false
         end
      end

      currentIndex = currentIndex % #explosions.list + 1

      -- Set all explosions in the new current index to active at once
      for _, explosion in ipairs(explosions.list[currentIndex]) do
         if not explosion.active then
            explosion.active = true
         end
      end

      -- Update explosionTimer after the loop
      explosionTimer = explosionDelay
   end
end

function explosions.draw()
   for _, explosionGroup in ipairs(explosions.list) do
      for _, explosion in ipairs(explosionGroup) do
         if explosion.active then
            local explosionX = (explosion.x - 1) * TILE_SIZE + TILE_SIZE / 2
            local explosionY = (explosion.y - 1) * TILE_SIZE + TILE_SIZE / 2

            love.graphics.setColor(explosion.r, explosion.g, explosion.b)
            love.graphics.circle("fill", explosionX, explosionY, TILE_SIZE / 2)
         end
      end
   end

   -- Reset color to white after drawing the explosions
   love.graphics.setColor(255, 255, 255)
end

return explosions