local minimap = {}

local TILE_SIZE = 32
local SCALE = 2 -- scale factor for the minimap
local CANVAS_WIDTH = 120
local CANVAS_HEIGHT = 80
local canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
canvas:setFilter("nearest", "nearest")

-- Define tile colors (edit to match your game style)
local tileColors = {
    ["s"] = {0.3, 0.3, 1.0},   -- spawn
    ["c"] = {0.0, 1.0, 0.3},   -- checkpoint
    ["e"] = {0.4, 0.3, 0.2},   -- end
    ["1"] = {0.6, 0.6, 0.6},   -- generic platform
    ["2"] = {0.5, 0.5, 0.5},
    ["3"] = {0.7, 0.7, 0.7},
    ["4"] = {0.7, 0.7, 0.7},
    ["5"] = {0.7, 0.7, 0.7},
    ["6"] = {0.7, 0.7, 0.7},
    ["7"] = {0.7, 0.7, 0.7},
    ["8"] = {0.7, 0.7, 0.7},
    ["9"] = {0.7, 0.7, 0.7},
    [" "] = {0, 0, 0, 0},      -- void
    ["0"] = {0.1, 0.1, 0.1},   -- dark space
}

function minimap.draw(zones, player)
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    local tileMap = zones.getTileMap()
    for y = 1, #tileMap do
        for x = 1, #tileMap[y] do
            local tile = tileMap[y][x]
            local color = tileColors[tile] or {0.8, 0.8, 0.8} -- fallback color

            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, 1, 1)
        end
    end

    -- Draw player position
    if player then
        local px = math.floor(player.x / TILE_SIZE) + 1
        local py = math.floor(player.y / TILE_SIZE) + 1
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", px, py, 1, 1)
    end

    love.graphics.setCanvas()

    -- Draw on screen (bottom-right corner by default)
    love.graphics.setColor(1, 1, 1)
    local margin = 10
    love.graphics.draw(
        canvas,
        love.graphics.getWidth() - (CANVAS_WIDTH * SCALE) - margin,
        love.graphics.getHeight() - (CANVAS_HEIGHT * SCALE) - margin,
        0,
        SCALE, SCALE
    )
end

return minimap