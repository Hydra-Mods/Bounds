local collision = {}

local player = require("player")
local zones = require("zones")

local TILE_SIZE = 32

local COLLIDABLE_TILES = {
   ["0"] = true,
   ["a"] = true,
   ["d"] = true,
   ["f"] = true,
   ["g"] = true,
   ["h"] = true,
   ["i"] = true,
   ["j"] = true,
   ["k"] = true,
   ["l"] = true,
   ["o"] = true,
   ["q"] = true,
   ["r"] = true,
   ["t"] = true,
   ["u"] = true,
   ["w"] = true,
   ["y"] = true,
}

local function tileAt(x, y, tileMap)
	return tileMap[y] and tileMap[y][x]
end

local function isBlocked(testX, testY, tileMap, width, height)
	local left = testX
	local right = testX + width
	local top = testY
	local bottom = testY + height

	local leftTileX = math.floor(left / TILE_SIZE) + 1
	local rightTileX = math.floor(right / TILE_SIZE) + 1
	local topTileY = math.floor(top / TILE_SIZE) + 1
	local bottomTileY = math.floor(bottom / TILE_SIZE) + 1

	return
		COLLIDABLE_TILES[tileAt(leftTileX, topTileY, tileMap)] or
		COLLIDABLE_TILES[tileAt(rightTileX, topTileY, tileMap)] or
		COLLIDABLE_TILES[tileAt(leftTileX, bottomTileY, tileMap)] or
		COLLIDABLE_TILES[tileAt(rightTileX, bottomTileY, tileMap)]
end

function collision.resolvePlayerCollision(x, y, vx, vy, dt, tileMap, width, height)
	local nextX = x + vx * dt
	local nextY = y + vy * dt

	-- Try X movement first
	local tryX = x + vx * dt
	if not isBlocked(tryX, y, tileMap, width, height) then
		x = tryX
	else
		vx = 0
	end

	-- Then try Y movement
	local tryY = y + vy * dt
	if not isBlocked(x, tryY, tileMap, width, height) then
		y = tryY
	else
		vy = 0
	end

	return x, y, vx, vy
end

function collision.checkCheckpointCollision(px, py, pw, ph)
	local TILE_SIZE = 32
	local zone = zones.data[zones.currentZone]
	if not zone or not zone.checkpointArea then return false end

	local a = zone.checkpointArea
	local cx = (a.x1 - 1) * TILE_SIZE
	local cy = (a.y1 - 1) * TILE_SIZE
	local cw = (a.x2 - a.x1 + 1) * TILE_SIZE
	local ch = (a.y2 - a.y1 + 1) * TILE_SIZE

	-- AABB (Axis-Aligned Bounding Box) check
	local overlap = px + pw > cx and px < cx + cw and py + ph > cy and py < cy + ch

	return overlap
end

return collision