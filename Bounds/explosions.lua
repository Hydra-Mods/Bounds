local explosions = {}

local explosionSets = {
	{
		love.graphics.newImage("Assets/Explosions/exp1.png"),
		love.graphics.newImage("Assets/Explosions/exp2.png"),
		love.graphics.newImage("Assets/Explosions/exp3.png"),
		love.graphics.newImage("Assets/Explosions/exp4.png"),
	},
	{
		love.graphics.newImage("Assets/Explosions/blue_exp1.png"),
		love.graphics.newImage("Assets/Explosions/blue_exp2.png"),
		love.graphics.newImage("Assets/Explosions/blue_exp3.png"),
		love.graphics.newImage("Assets/Explosions/blue_exp4.png"),
	},
}

local TILE_SIZE = 32
local frameDuration = 0.1
local explosionDuration = 4 * frameDuration -- 4 is the frames
local activeExplosions = {} -- Table of active explosions

function explosions.spawn(tileX, tileY, color, setIndex)
	for _, exp in ipairs(activeExplosions) do
		if exp.x == tileX and exp.y == tileY then return end
	end

	setIndex = setIndex or 1

	table.insert(activeExplosions, {
		x = tileX,
		y = tileY,
		color = color or {255, 255, 0},
		timer = 0,
		set = explosionSets[setIndex]
	})
end

function explosions.update(dt)
	for i = #activeExplosions, 1, -1 do
		local exp = activeExplosions[i]
		exp.timer = exp.timer + dt

		if exp.timer >= explosionDuration then
			table.remove(activeExplosions, i)
		end
	end
end

function explosions.draw()
	for _, exp in ipairs(activeExplosions) do
		local frames = exp.set
		local frameIndex = math.min(math.floor(exp.timer / frameDuration) + 1, #frames)
		local img = frames[frameIndex]
		local imageWidth, imageHeight = img:getDimensions()
		local scale = TILE_SIZE / math.max(imageWidth, imageHeight)

		local px = (exp.x - 1) * TILE_SIZE + TILE_SIZE / 2
		local py = (exp.y - 1) * TILE_SIZE + TILE_SIZE / 2

		local progress = exp.timer / explosionDuration
		local alpha = 255 * (1 - progress^2)

		love.graphics.setColor(exp.color[1], exp.color[2], exp.color[3], alpha)
		love.graphics.draw(img, px, py, 0, scale, scale, imageWidth / 2, imageHeight / 2)
	end

	love.graphics.setColor(255, 255, 255)
end

function explosions.clear()
	activeExplosions = {}
end

function explosions.isTileExploding(tileX, tileY)
	for _, exp in ipairs(activeExplosions) do
		if exp.x == tileX and exp.y == tileY then
			return true
		end
	end
	return false
end

return explosions