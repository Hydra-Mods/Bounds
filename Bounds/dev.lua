local dev = {}

local TILE_SIZE = 32
local showDebug = false

function dev.toggle()
    showDebug = not showDebug
end

function dev.draw(player, zones)
    if not showDebug then return end

    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)

    local mx, my = love.mouse.getPosition()
    local tileX = math.floor(mx / TILE_SIZE) + 1
    local tileY = math.floor(my / TILE_SIZE) + 1

    local tileVal = zones.getTileMap()[tileY] and zones.getTileMap()[tileY][tileX] or "nil"
    love.graphics.print("Mouse Tile: (" .. tileX .. ", " .. tileY .. ") = " .. tostring(tileVal), 10, 10)

    -- Nearby tile grid under mouse
    for dy = -1, 1 do
        for dx = -1, 1 do
            local tx, ty = tileX + dx, tileY + dy
            local tVal = zones.getTileMap()[ty] and zones.getTileMap()[ty][tx] or " "
            love.graphics.print(tVal, 300 + dx * 20, 10 + dy * 20)
        end
    end

    -- Player tile and pixel position
    local px = math.floor(player.x / TILE_SIZE) + 1
    local py = math.floor(player.y / TILE_SIZE) + 1
    love.graphics.print("Player Tile: (" .. px .. ", " .. py .. ")", 10, 30)
    love.graphics.print(string.format("Player Pos: %.1f, %.1f", player.x, player.y), 10, 45)

    local z = zones.data[zones.currentZone]
    if z then
        love.graphics.print("Zone ID: " .. z.id, 10, 65)

        -- Checkpoint area
        if z.checkpointArea then
            love.graphics.setColor(0, 1, 0, 0.3)
            local a = z.checkpointArea
            love.graphics.rectangle("fill", (a.x1 - 1) * TILE_SIZE, (a.y1 - 1) * TILE_SIZE, (a.x2 - a.x1 + 1) * TILE_SIZE, (a.y2 - a.y1 + 1) * TILE_SIZE)
        end

        -- Spawn point area (convert pixels to tile)
        if zones.spawnPoint then
            love.graphics.setColor(0, 0, 1, 0.3)
            local sx = math.floor(zones.spawnPoint.x / TILE_SIZE) * TILE_SIZE
            local sy = math.floor(zones.spawnPoint.y / TILE_SIZE) * TILE_SIZE
            love.graphics.rectangle("fill", sx, sy, TILE_SIZE, TILE_SIZE)
        end
    end

    -- Highlight hovered tile
    love.graphics.setColor(1, 0, 0, 0.6)
    love.graphics.rectangle("line", (tileX - 1) * TILE_SIZE, (tileY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)

    -- Grid overlay
    love.graphics.setColor(1, 1, 1, 0.1)
    for y = 0, love.graphics.getHeight(), TILE_SIZE do
        love.graphics.line(0, y, love.graphics.getWidth(), y)
    end
    for x = 0, love.graphics.getWidth(), TILE_SIZE do
        love.graphics.line(x, 0, x, love.graphics.getHeight())
    end

    -- Player collision box
    love.graphics.setColor(1, 1, 0, 0.3)
    love.graphics.rectangle("fill", player.x, player.y, player.width or TILE_SIZE, player.height or TILE_SIZE)

    -- FPS & memory
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, love.graphics.getHeight() - 40)
    love.graphics.print(string.format("Memory: %.2f MB", collectgarbage("count") / 1024), 10, love.graphics.getHeight() - 25)
end

function dev.keypressed(key, zones)
    if not showDebug then return end
    if key == "r" then
        local z = zones.data[zones.currentZone]
        if z and z.triggerFile then
            zones.loadedTriggers = love.filesystem.load(z.triggerFile)()
            print("Reloaded trigger file:", z.triggerFile)
        end
    end
end

return dev