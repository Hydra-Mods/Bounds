local camera = {
	x = 0, y = 0,
	targetX = 0, targetY = 0,
	speed = 6, -- tiles per second
}

local speed = 6

function camera.moveTo(x, y)
	if camera.targetX ~= x or camera.targetY ~= y then
		camera.targetX = x
		camera.targetY = y
	end
end

function camera.update(dt)
	local ease = 1 - math.exp(-camera.speed * dt)
	camera.x = camera.x + (camera.targetX - camera.x) * ease
	camera.y = camera.y + (camera.targetY - camera.y) * ease
end

function camera.getOffset()
	return -camera.x * 32, -camera.y * 32 -- TILE_SIZE = 32
end

return camera