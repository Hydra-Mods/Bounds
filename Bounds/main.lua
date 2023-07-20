local ui = require("ui")
local level = require("level")
local collision = require("collision")
local triggers = require("triggers1")
local gamestate = require("gamestate")

local startscreen = require("startscreen")
local gamescreen = require("gamescreen")
local endscreen = require("endscreen")
local scorescreen = require("scorescreen")

function love.load()
   -- Set up the game states
   gamestate.registerState("startscreen", startscreen)
   gamestate.registerState("gamescreen", gamescreen)
   gamestate.registerState("endscreen", endscreen)
   gamestate.registerState("scorescreen", scorescreen)

   -- Set the initial game state to start screen
   gamestate.setState("startscreen")
end

function love.update(dt)
   -- Update the current game state
   --gamestate.currentState.update(dt)
   gamestate.update(dt)
end

function love.draw()
   -- Draw the current game state
   gamestate.currentState.draw()
end

function love.keypressed(key)
   -- Pass keypress events to the current game state
   gamestate.currentState.keypressed(key)
end

function love.mousepressed(x, y, button)
   -- Pass mouse click events to the current game state
   gamestate.currentState.mousepressed(x, y, button)
end