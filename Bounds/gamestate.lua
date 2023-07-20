local gamestate = {}

gamestate.states = {}

function gamestate.registerState(stateName, reference)
    gamestate.states[stateName] = reference
end

function gamestate.setState(stateName)
    if gamestate.currentState and gamestate.currentState.exit then
        gamestate.currentState.exit()
    end

    gamestate.currentState = gamestate.states[stateName]

    if gamestate.currentState and gamestate.currentState.enter then
        gamestate.currentState.enter()
    end
end

function gamestate.update(dt)
    if gamestate.currentState and gamestate.currentState.update then
        gamestate.currentState.update(dt)
    end
end

return gamestate