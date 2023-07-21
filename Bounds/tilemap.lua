local tilemap = {}

local TILE_SIZE = 32

local tileImages = {
   ["s"] = love.graphics.newImage("Assets/s.png"),
   ["e"] = love.graphics.newImage("Assets/e.png"),
   ["0"] = love.graphics.newImage("Assets/0.png"),
   ["1"] = love.graphics.newImage("Assets/1.png"),
   ["2"] = love.graphics.newImage("Assets/2.png"),
   ["3"] = love.graphics.newImage("Assets/3.png"),
   ["4"] = love.graphics.newImage("Assets/4.png"),
   ["5"] = love.graphics.newImage("Assets/5.png"),
   ["6"] = love.graphics.newImage("Assets/6.png"),
   ["7"] = love.graphics.newImage("Assets/7.png"),
   ["8"] = love.graphics.newImage("Assets/8.png"),
   ["9"] = love.graphics.newImage("Assets/9.png"),
}

function tilemap.load()
   return level.load() -- Replace 'level.load()' with the actual function to load the tile map
end

function tilemap.draw(tileMap)
   for y = 1, #tileMap do
      for x = 1, #tileMap[y] do
         local tileType = tileMap[y][x]
         local tileImage = tileImages[tileType]

         love.graphics.draw(tileImage, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
      end
   end
end

return tilemap