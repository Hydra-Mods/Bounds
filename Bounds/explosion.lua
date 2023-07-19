local explosion = {}

local explosions = {}

function explosion.loadSequencesFromCSV(file)
   -- Load explosion sequences from CSV file and store them in the 'explosions' table
   for line in love.filesystem.lines(file) do
      local x, y, delay, r, g, b = line:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
      table.insert(explosions, {
         x = tonumber(x),
         y = tonumber(y),
         delay = tonumber(delay),
         r = tonumber(r),
         g = tonumber(g),
         b = tonumber(b),
         active = false,
         alpha = 255
      })
   end
end

function explosion.getCurrentExplosions()
   -- Return the current list of explosions
   return explosions
end

return explosion