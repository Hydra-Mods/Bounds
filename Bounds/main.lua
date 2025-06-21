local gamestate = require("gamestate")
local titlescreen = require("titlescreen")
local gamescreen = require("gamescreen")
local settingsscreen = require("settingsscreen")
local audio = require("audio")
local settings = require("settings")

function love.load()
	love.window.setTitle("Bounds")

	love.graphics.setDefaultFilter("nearest", "nearest")

	settings.load()
	audio.load()
	audio.playMusic()

	-- Set up the game states
	gamestate.registerState("titlescreen", titlescreen)
	gamestate.registerState("gamescreen", gamescreen)
	gamestate.registerState("settingsscreen", settingsscreen)

	-- Set the initial game state to start screen
	gamestate.setState("titlescreen")
end

function love.update(dt)
	gamestate.update(dt)
end

function love.draw()
	gamestate.currentState.draw()
end

function love.keypressed(key)
	gamestate.currentState.keypressed(key)
end

function love.gamepadpressed(joystick, button)
	if gamestate.currentState.gamepadpressed then
		gamestate.currentState.gamepadpressed(joystick, button)
	end
end

function love.mousepressed(x, y, button)
	gamestate.currentState.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	if gamestate.currentState.mousereleased then
		gamestate.currentState.mousereleased(x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy)
	if gamestate.currentState.mousemoved then
		gamestate.currentState.mousemoved(x, y, dx, dy)
	end
end