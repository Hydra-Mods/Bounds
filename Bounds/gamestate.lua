local gamestate = {}

gamestate.states = {}
gamestate.currentState = nil
gamestate.previousState = nil
gamestate.currentStateName = nil
gamestate.previousStateName = nil

function gamestate.registerState(name, reference)
    gamestate.states[name] = reference
end

function gamestate.setState(name, ...)
    if gamestate.currentState and gamestate.currentState.exit then
        gamestate.currentState.exit()
    end

    gamestate.previousState = gamestate.currentState
    gamestate.previousStateName = gamestate.currentStateName

    gamestate.currentState = gamestate.states[name]
    gamestate.currentStateName = name

    if gamestate.currentState and gamestate.currentState.enter then
        gamestate.currentState.enter(...)
    end
end

function gamestate.returnToPreviousState()
    if gamestate.previousStateName then
        gamestate.setState(gamestate.previousStateName)
    end
end

function gamestate.update(dt)
    if gamestate.currentState and gamestate.currentState.update then
        gamestate.currentState.update(dt)
    end
end

return gamestate