local level = {}
local explosion = require("explosion")

local currentLevel = 1
local totalLevels = 3  -- Update with the total number of levels you have

function level.load()
   -- Load the tile map from the current level file
   local file = string.format("level%s.csv", currentLevel)
   local tileMap = {}

   for line in love.filesystem.lines(file) do
      local row = {}
      for tile in line:gmatch("[^,]+") do
         table.insert(row, tile)
      end
      table.insert(tileMap, row)
   end

   -- Load the explosion sequences for the current level
   local explosionFile = string.format("explosion%s.csv", currentLevel)
   local explosionSequences = explosion.loadSequencesFromCSV(explosionFile)

   return tileMap, explosionSequences
end

function level.nextLevel()
   currentLevel = currentLevel + 1
   if currentLevel > totalLevels then
      currentLevel = 1
   end
   return level.load()
end

function level.getCurrentLevel()
   return currentLevel
end

function level.reset()
   currentLevel = 1
end

return level