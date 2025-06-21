local zones = {}

local camera = require("camera")
local triggers = require("triggers")
local audio = require("audio")
local ui = require("ui")

zones.current = 1
zones.currentZone = nil
zones.loadedTriggers = {}
zones.tileMap = {}
zones.spawnPoints = {}

local TILE_SIZE = 32

zones.data = {
	{
		id = 1, -- Training Grounds
		spawn = { x = 4, y = 10 },
		checkpointArea = { x1 = 21, y1 = 9, x2 = 23, y2 = 11 },
		triggerFile = "Triggers/zone1.lua",
		cameraFocus = { x = 0, y = 0},
	},
	{
		id = 2,
		spawn = { x = 18, y = 10 },
		checkpointArea = { x1 = 39, y1 = 9, x2 = 42, y2 = 11 },
		triggerFile = "Triggers/zone2.lua",
		cameraFocus = { x = 18, y = 0 },
	},
	{
		id = 3,
		spawn = { x = 22, y = 10 },
		checkpointArea = { x1 = 57, y1 = 9, x2 = 59, y2 = 11 },
		triggerFile = "Triggers/zone3.lua",
		cameraFocus = { x = 36, y = 0 },
	},
	{
		id = 3,
		spawn = { x = 58, y = 10 },
		checkpointArea = { x1 = 67, y1 = 9, x2 = 69, y2 = 11 },
		triggerFile = "Triggers/zone3.lua",
		cameraFocus = { x = 54, y = 0 },
	},
}

function zones.loadWorld()
	local file = "world.csv"
	local tileMap = {}

	for line in love.filesystem.lines(file) do
		local row = {}
		for tile in line:gmatch("[^,]+") do
			table.insert(row, tile)
		end
		table.insert(tileMap, row)
	end

	zones.tileMap = tileMap

   -- Set initial spawn from zones.data[1].spawn tile coordinates
	local spawn = zones.data[1].spawn
	zones.initialSpawnPoint = {
		x = (spawn.x - 1) * TILE_SIZE + TILE_SIZE / 2,
		y = (spawn.y - 1) * TILE_SIZE + TILE_SIZE / 2,
		width = TILE_SIZE,
		height = TILE_SIZE
	}

	zones.spawnPoint = zones.initialSpawnPoint
end

function zones.getTileMap()
	return zones.tileMap
end

function zones.checkCheckpoint()
	local nextZone = zones.data[zones.currentZone + 1]
	if nextZone then
		audio.playSFX("checkpoint")
		ui.triggerCheckpointPopup()
		zones.enterZone(nextZone)
	end
end

function zones.enterZone(zone)
	zones.currentZone = zone.id
	zones.current = zone.id
	zones.loadedTriggers = love.filesystem.load(zone.triggerFile)()

	-- Set spawn point from previous zone's checkpointArea, if any
	local previousZone = zones.data[zone.id - 1]
	if previousZone and previousZone.checkpointArea then
		local a = previousZone.checkpointArea
		zones.spawnPoint = {
			x = ((a.x1 + a.x2) / 2 - 1) * TILE_SIZE + TILE_SIZE / 2,
			y = ((a.y1 + a.y2) / 2 - 1) * TILE_SIZE + TILE_SIZE / 2,
			width = TILE_SIZE,
			height = TILE_SIZE
		}
	end

	local currentTriggers = zones.getCurrentZoneTriggers()
	triggers.set(currentTriggers)
	camera.moveTo(zone.cameraFocus.x, zone.cameraFocus.y)
end

function zones.getCurrentZoneTriggers()
	return zones.loadedTriggers
end

return zones