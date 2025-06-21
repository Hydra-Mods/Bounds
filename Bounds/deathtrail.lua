local deathTrail = {}

function deathTrail.add(x, y)
	table.insert(deathTrail, {x = x, y = y, alpha = 0.25})
end

function deathTrail.update(dt)
	for i = #deathTrail, 1, -1 do
		local d = deathTrail[i]
		d.alpha = d.alpha - dt * 0.5
		if d.alpha <= 0 then
			table.remove(deathTrail, i)
		end
	end
end

function deathTrail.draw()
	for _, d in ipairs(deathTrail) do
		love.graphics.setColor(1, 0.2, 0.2, d.alpha)
		love.graphics.circle("fill", d.x, d.y, 6)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

return deathTrail