local triggers = require("triggers")
local explosions = require("explosions")

local TILE_SIZE = 32
local bot = {
    x = 0,
    y = 0,
    width = TILE_SIZE,
    height = TILE_SIZE,
    path = {},
    speed = 180,
    currentTarget = 1,
    active = false
}

function bot.start(startX, startY, goalX, goalY, tileMap)
    bot.x = (startX - 1) * TILE_SIZE
    bot.y = (startY - 1) * TILE_SIZE
    bot.path = bot.findPath(tileMap, startX, startY, goalX, goalY)
    bot.currentTarget = 1
    bot.active = true

    print("Bot starting path from:", startX, startY, "to", goalX, goalY)
    if #bot.path == 0 then
        print("No path found!")
    else
        for i, step in ipairs(bot.path) do
            print(i, "->", step[1], step[2])
        end
    end
end

function bot.tileAtX()
    return math.floor(bot.x / TILE_SIZE) + 1
end

function bot.tileAtY()
    return math.floor(bot.y / TILE_SIZE) + 1
end

function bot.update(dt)
    if not bot.active or #bot.path == 0 or bot.currentTarget > #bot.path then return end

    local tx, ty = bot.path[bot.currentTarget][1], bot.path[bot.currentTarget][2]
    local targetX = (tx - 1) * TILE_SIZE
    local targetY = (ty - 1) * TILE_SIZE

    local dx = targetX - bot.x
    local dy = targetY - bot.y
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist < 2 then
        bot.x = targetX
        bot.y = targetY
        bot.currentTarget = bot.currentTarget + 1
    else
        bot.x = bot.x + (dx / dist) * bot.speed * dt
        bot.y = bot.y + (dy / dist) * bot.speed * dt
    end
end

function bot.draw()
    -- Draw path
    love.graphics.setColor(0, 1, 1, 0.5)
    for _, node in ipairs(bot.path) do
        love.graphics.rectangle("line", (node[1] - 1) * TILE_SIZE, (node[2] - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    end

    -- Draw bot
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("fill", bot.x, bot.y, bot.width, bot.height)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Returns true if the tile at x, y has a trigger that causes danger
function triggers.isDangerousTrigger(x, y)
    for _, t in ipairs(triggerList or {}) do
        if t.x == x and t.y == y and t.type == "explode" then
            return true
        end
    end
    return false
end

-- A* pathfinding (basic example)
function bot.findPath(map, startX, startY, goalX, goalY)
    local openSet = { {startX, startY} }
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    local function key(x, y) return x .. "," .. y end
	local function neighbors(x, y)
		local result = {}
		for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
			local nx, ny = x + d[1], y + d[2]

			local walkable = map[ny] and map[ny][nx] and map[ny][nx] ~= "0" and map[ny][nx] ~= "9"
			local isExploding = explosions.isTileExploding(nx, ny)
			local isTrigger = triggers.isDangerousTrigger(nx, ny)

			if walkable and not isExploding and not isTrigger then
				table.insert(result, {nx, ny})
			end
		end
		return result
	end

    local function heuristic(a, b)
        return math.abs(a[1] - b[1]) + math.abs(a[2] - b[2])
    end

    gScore[key(startX, startY)] = 0
    fScore[key(startX, startY)] = heuristic({startX, startY}, {goalX, goalY})

    while #openSet > 0 do
        table.sort(openSet, function(a, b)
            return (fScore[key(a[1], a[2])] or math.huge) < (fScore[key(b[1], b[2])] or math.huge)
        end)

        local current = table.remove(openSet, 1)
        local cx, cy = current[1], current[2]

        if cx == goalX and cy == goalY then
            local path = {}
            while current do
                table.insert(path, 1, current)
                current = cameFrom[key(current[1], current[2])]
            end
            return path
        end

        for _, neighbor in ipairs(neighbors(cx, cy)) do
            local nx, ny = neighbor[1], neighbor[2]
            local tentative_g = (gScore[key(cx, cy)] or math.huge) + 1
            if tentative_g < (gScore[key(nx, ny)] or math.huge) then
                cameFrom[key(nx, ny)] = {cx, cy}
                gScore[key(nx, ny)] = tentative_g
                fScore[key(nx, ny)] = tentative_g + heuristic({nx, ny}, {goalX, goalY})

                local found = false
                for _, o in ipairs(openSet) do
                    if o[1] == nx and o[2] == ny then found = true break end
                end
                if not found then table.insert(openSet, {nx, ny}) end
            end
        end
    end

    return {}
end

return bot