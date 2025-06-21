local effects = {}
local puffFrames = {}
local puffAnimations = {}
local TILE_SIZE = 32
local FRAME_TIME = 0.05  -- 20 FPS

function effects.load()
    for i = 1, 5 do
        puffFrames[i] = love.graphics.newImage("Assets/Death/death" .. i .. ".png")
    end
end

function effects.spawnPuff(x, y)
    table.insert(puffAnimations, {
        x = x,
        y = y,
        frame = 1,
        timer = 0
    })
end


function effects.update(dt)
    for i = #puffAnimations, 1, -1 do
        local puff = puffAnimations[i]
        puff.timer = puff.timer + dt
        if puff.timer >= FRAME_TIME then
            puff.timer = 0
            puff.frame = puff.frame + 1
            if puff.frame > #puffFrames then
                table.remove(puffAnimations, i)
            end
        end
    end
end

function effects.draw()
    for _, puff in ipairs(puffAnimations) do
        local img = puffFrames[puff.frame]
        if img then
            love.graphics.draw(img, puff.x, puff.y)
        end
    end
end

return effects