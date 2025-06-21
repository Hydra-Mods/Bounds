local parallax = {
   layers = {}
}

function parallax.load()
	table.insert(parallax.layers, {
		image = love.graphics.newImage("Assets/Backgrounds/starfield.png"),
		speed = 0.2,
		alpha = 1,
		scale = 1,
	})
end

function parallax.draw(camX, camY)
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()

	for _, layer in ipairs(parallax.layers) do
		local img = layer.image
		local scale = layer.speed or 1
		local imgW = img:getWidth()
		local imgH = img:getHeight()

		-- Calculate horizontal offset (parallax in X only)
		local offsetX = (camX * scale) % imgW
		if offsetX < 0 then offsetX = offsetX + imgW end
		offsetX = math.floor(offsetX + 0.5)

		local offsetY = 0 -- fixed Y offset for side-scroll

		for x = -imgW, screenWidth + imgW, imgW do
			for y = 0, screenHeight, imgH do
				love.graphics.setColor(1, 1, 1, layer.alpha or 1)
				love.graphics.draw(img, x - offsetX, y, 0, layer.scale or 1)
			end
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

return parallax