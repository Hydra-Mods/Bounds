local ui = {}

local nineslice = require("nineslice")
local pause = require("pause")

local currentLevel = 1
local startTime = 0
local levelCompleteTime = 0
local respawnCount = 0
local elapsedTime = 0

-- === Theme Colors and Fonts ===
local spaceBlue = {0.92, 0.96, 1.0}     -- Main text
local textFont = love.graphics.newFont("Assets/Orbitron-Regular.ttf", 20)
local headingFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 32)
local monoFont = love.graphics.newFont("Assets/RobotoMono.ttf", 20)
local uiBoxImage = love.graphics.newImage("Assets/UI_box.png")

-- === Checkpoint Popup ===
local checkpointPopup = {
	visible = false,
	timer = 0,
	duration = 2.4,
	alpha = 1,
}

function ui.triggerCheckpointPopup()
	checkpointPopup.visible = true
	checkpointPopup.timer = 0
	checkpointPopup.alpha = 1
end

function ui.initLevel(level)
	currentLevel = level
	startTime = love.timer.getTime()
	levelCompleteTime = 0
	respawnCount = 0
end

local function formatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%05.2f", mins, secs)
end

function ui.updateTimer()
	return formatTime(elapsedTime)
end

function ui.startTimer()
	elapsedTime = 0
end

function ui.getLevelCompleteTime()
	return levelCompleteTime
end

function ui.setLevelCompleteTime(time)
	levelCompleteTime = time
end

function ui.getCurrentLevel()
	return currentLevel
end

function ui.setCurrentLevel(level)
	currentLevel = level
end

function ui.markLevelComplete()
	levelCompleteTime = love.timer.getTime() - startTime
end

function ui.incrementRespawns()
	respawnCount = respawnCount + 1
end

function ui.getRespawnCount()
	return respawnCount
end

function ui.resetRespawns()
	respawnCount = 0
end

local function drawGlowText(text, x, y, font, color)
	love.graphics.setFont(font)
	love.graphics.setColor(0.1, 0.15, 0.2, 0.5)
	for dx = -1, 1 do
		for dy = -1, 1 do
			love.graphics.print(text, x + dx, y + dy)
		end
	end
	love.graphics.setColor(color)
	love.graphics.print(text, x, y)
	love.graphics.setColor(1, 1, 1, 1)
end

function ui.drawLevelIndicator(x, y)
	x = x or 20
	y = y or 20
	local text = "Level: " .. currentLevel
	drawGlowText(text, x, y, textFont, spaceBlue)
end

function ui.drawRespawns(x, y)
	x = x or 20
	y = y or 50
	local text = "Respawns: " .. respawnCount
	drawGlowText(text, x, y, textFont, spaceBlue)
end

function ui.drawTimer()
	local timerText = ui.updateTimer()
	local x = love.graphics.getWidth() / 2 - monoFont:getWidth(timerText) / 2
	drawGlowText(timerText, x, 20, monoFont, spaceBlue)
end

function ui.drawCheckpointPopup()
	if checkpointPopup.visible then
		local dt = love.timer.getDelta()
		checkpointPopup.timer = checkpointPopup.timer + dt

		if checkpointPopup.timer >= checkpointPopup.duration then
			checkpointPopup.visible = false
		else
			local progress = checkpointPopup.timer / checkpointPopup.duration
			checkpointPopup.alpha = 1 - progress

			local text = "CHECKPOINT REACHED"
			love.graphics.setFont(headingFont)

			-- Smooth scale in from 0.8 to 1.0 (ease-out)
			local scale = 0.8 + (1 - math.pow(1 - progress, 3)) * 0.2

			-- Rise upward gently over time
			local baseY = love.graphics.getHeight() / 2 - 180
			local rise = 60
			local y = baseY - (progress * rise)

			local textWidth = headingFont:getWidth(text)
			local screenW = love.graphics.getWidth()

			love.graphics.setColor(spaceBlue[1], spaceBlue[2], spaceBlue[3], checkpointPopup.alpha)

			love.graphics.push()
			love.graphics.translate(screenW / 2, y)
			love.graphics.scale(scale, scale)
			love.graphics.printf(text, -textWidth / 2, 0, textWidth, "center")
			love.graphics.pop()
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

local function snapToMultiple(value, multiple)
	return math.ceil(value / multiple) * multiple
end

function ui.draw()
	-- Top Left Box
	local boxX, boxY = 10, 10
	local boxWidth, boxHeight = 208, 80 -- already clean
	nineslice.draw(uiBoxImage, boxX, boxY, boxWidth, boxHeight)

	ui.drawLevelIndicator(boxX + 10, boxY + 10)
	ui.drawRespawns(boxX + 10, boxY + 40)

	-- Center Timer Box
	local timerText = ui.updateTimer()
	local textWidth = monoFont:getWidth(timerText)
	local textHeight = monoFont:getHeight()
	local padding = 20

	local rawW = textWidth + padding * 2
	local rawH = textHeight + padding
	local timerBoxWidth = snapToMultiple(rawW, 16)
	local timerBoxHeight = snapToMultiple(rawH, 16)

	local timerBoxX = love.graphics.getWidth() / 2 - timerBoxWidth / 2
	local timerBoxY = 10

	nineslice.draw(uiBoxImage, timerBoxX, timerBoxY, timerBoxWidth, timerBoxHeight)

	local textX = timerBoxX + (timerBoxWidth - textWidth) / 2
	local textY = timerBoxY + (timerBoxHeight - textHeight) / 2
	drawGlowText(timerText, textX, textY, monoFont, spaceBlue)

	-- Checkpoint popup
	ui.drawCheckpointPopup()
end

function ui.update(dt)
	if not pause.isActive() then
		elapsedTime = elapsedTime + dt
	end
end

return ui