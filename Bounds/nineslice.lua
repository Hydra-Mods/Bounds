local nineslice = {}

nineslice.draw = function(image, x, y, width, height)
    local slice = 16
    local iw, ih = image:getWidth(), image:getHeight()

    local quads = {
        love.graphics.newQuad(0,     0,     slice, slice, iw, ih), -- Top-left
        love.graphics.newQuad(slice, 0,     slice, slice, iw, ih), -- Top
        love.graphics.newQuad(slice*2, 0,   slice, slice, iw, ih), -- Top-right
        love.graphics.newQuad(0,     slice, slice, slice, iw, ih), -- Left
        love.graphics.newQuad(slice, slice, slice, slice, iw, ih), -- Center
        love.graphics.newQuad(slice*2, slice, slice, slice, iw, ih), -- Right
        love.graphics.newQuad(0,     slice*2, slice, slice, iw, ih), -- Bottom-left
        love.graphics.newQuad(slice, slice*2, slice, slice, iw, ih), -- Bottom
        love.graphics.newQuad(slice*2, slice*2, slice, slice, iw, ih), -- Bottom-right
    }

    local cols = math.floor((width - 2 * slice) / slice)
    local rows = math.floor((height - 2 * slice) / slice)

    -- Corners
    love.graphics.draw(image, quads[1], x, y)
    love.graphics.draw(image, quads[3], x + width - slice, y)
    love.graphics.draw(image, quads[7], x, y + height - slice)
    love.graphics.draw(image, quads[9], x + width - slice, y + height - slice)

    -- Top / Bottom edges
    for i = 1, cols do
        love.graphics.draw(image, quads[2], x + i * slice, y)
        love.graphics.draw(image, quads[8], x + i * slice, y + height - slice)
    end

    -- Left / Right edges
    for j = 1, rows do
        love.graphics.draw(image, quads[4], x, y + j * slice)
        love.graphics.draw(image, quads[6], x + width - slice, y + j * slice)
    end

    -- Center fill
    for i = 1, cols do
        for j = 1, rows do
            love.graphics.draw(image, quads[5], x + i * slice, y + j * slice)
        end
    end
end

return nineslice