local gamestate = {}

gamestate.states = {}

function gamestate.registerState(stateName, enterFunc, updateFunc, exitFunc)
    gamestate.states[stateName] = {
        enter = enterFunc,
        update = updateFunc,
        exit = exitFunc
    }
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