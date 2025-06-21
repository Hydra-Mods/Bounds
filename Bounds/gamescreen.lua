local gamescreen = {}

local ui = require("ui")
local collision = require("collision")
local gamestate = require("gamestate")
local player = require("player")
local controls = require("controls")
local tilemap = require("tilemap")
local explosions = require("explosions")
local camera = require("camera")
local zones = require("zones")
local triggers = require("triggers")
local parallax = require("parallax")
local minimap = require("minimap")
local deathtrail = require("deathtrail")
local effects = require("effects")
local nineslice = require("nineslice")
local pause = require("pause")
--local bot = require("bot")
local dev = require("dev")

-- Game state variables
local currentTileMap = {}
local gameWon = false
local levelComplete = false
local startTime = 0
local levelCompleteTime = 0
local currentTime = 0
local debugMessage = ""

local TILE_SIZE = 32
local PLAYER_COLLISION_THRESHOLD = 16

function gamescreen.enter()
   zones.loadWorld()
	zones.enterZone(zones.data[1])
   currentTileMap = zones.getTileMap()
   triggerTimer = 0
   triggerIndex = 1
   explosions.clear()

	local playerSize = TILE_SIZE / 2
	local sp = zones.initialSpawnPoint
	zones.spawnPoint = sp

	-- Center player on tile
	local spawnX = sp.x - playerSize / 2
	local spawnY = sp.y - playerSize / 2

	player.initialize(spawnX, spawnY, playerSize)

   ui.initLevel(1)

   parallax.load() -- ?
   effects.load()

   --bot.start(4, 10, 22, 10, zones.getTileMap())
end

function gamescreen.exit()
end

function gamescreen.update(dt)
   if pause.isActive() then return end

   controls.handleInput()

   local px, py = player.getPosition()
   local vx, vy = player.getVelocity()
   local pw, ph = player.width, player.height

   camera.update(dt)

   local newX, newY, newVX, newVY = collision.resolvePlayerCollision(
      px, py, vx, vy, dt, currentTileMap, pw, ph
   )

   player.setPosition(newX, newY)
   player.setVelocity(newVX, newVY)

	triggers.update(dt)
   explosions.update(dt)

	if collision.checkCheckpointCollision(px, py, pw, ph) then
	   debugMessage = "Inside checkpoint area"
	   zones.checkCheckpoint()
	else
	   debugMessage = ""
	end

   local left = math.floor(px / TILE_SIZE) + 1
   local right = math.floor((px + pw - 1) / TILE_SIZE) + 1
   local top = math.floor(py / TILE_SIZE) + 1
   local bottom = math.floor((py + ph - 1) / TILE_SIZE) + 1

   for ty = top, bottom do
      for tx = left, right do
         if explosions.isTileExploding(tx, ty) then
			effects.spawnPuff(px, py)
			deathtrail.add(px + pw / 2, py + ph / 2)
			local sp = zones.spawnPoint
			local spawnX = sp.x - player.width / 2
			local spawnY = sp.y - player.height / 2
			player.setPosition(spawnX, spawnY)
            ui.incrementRespawns()
            return
         end
      end
   end

	effects.update(dt)
	ui.update(dt)

   currentTime = ui.updateTimer()

   --bot.update(dt)
end

function gamescreen.draw()
   love.graphics.push()
   local camX, camY = camera.getOffset()
   parallax.draw(camX, camY)
   love.graphics.translate(camX, camY)

   tilemap.draw()
   explosions.draw()
   effects.draw()
   player.draw()
	deathtrail.draw()
   love.graphics.pop()

   ui.draw()
   --minimap.draw(zones, player)

   --[[ debug tile text
	for y = 1, #currentTileMap do
	   for x = 1, #currentTileMap[y] do
		  local tile = currentTileMap[y][x]
		  if tile and tile ~= "0" then
			 love.graphics.setColor(1, 1, 1)
			 love.graphics.print(tile, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
		  end
	   end
	end]]

	dev.draw(player, zones)
	--bot.draw()

   if pause.isActive() then
      pause.draw()
   end
end

function gamescreen.mousepressed(x, y, button)
   if pause.mousepressed(x, y, button) then return end
end

function gamescreen.gamepadpressed(joystick, button)
   if pause.handleGamepadPressed(joystick, button) then return end
end

function gamescreen.keypressed(key)
	if pause.handleKey(key) then return end

    if key == "f1" or key == "`" then
        dev.toggle()
    end
end

return gamescreen