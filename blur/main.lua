local numbers = {}

local numbers_subtbl_mt = {
    __index = function(tbl, idx)
        local val = rawget(tbl, idx)
        if val == nil then
            return {0, 0, 0}
        else
            return val
        end
    end
}

local numbers_mt = {
    __index = function(tbl, idx)
        local val = rawget(tbl, idx)
        if val == nil then
            local ret = {}
            setmetatable(ret, numbers_subtbl_mt)
            return ret
        else
            return val 
        end
    end
}

setmetatable(numbers, numbers_mt)

local Xdim = 200
local Ydim = 200

for i = 1, Xdim, 1 do
    numbers[i] = {}
    setmetatable(numbers[i], numbers_subtbl_mt)
    for f = 1, Ydim, 1 do
        numbers[i][f] = {love.math.random(0, 255)/255, love.math.random(0, 255)/255, love.math.random(0, 255)/255}
    end
end

local function processBlur(numbers)
    local ret = {}
    setmetatable(ret, numbers_mt)
    for i = 1, Xdim, 1 do
        ret[i] = {}
        setmetatable(ret[i], numbers_subtbl_mt)
        for f = 1, Ydim, 1 do
            local avg_vals = {numbers[i][f], numbers[i+1][f], numbers[i-1][f], numbers[i][f+1], numbers[i][f-1], numbers[i+1][f+1], numbers[i+1][f-1], numbers[i-1][f-1], numbers[i-1][f+1]}
            local avg_red = 0
            local avg_green = 0
            local avg_blue = 0

            local keep = 0.009

            for k = 1, #avg_vals, 1 do
                avg_red = avg_red + avg_vals[k][1] + (numbers[i][f][1]*keep)
                avg_green = avg_green + avg_vals[k][2] + (numbers[i][f][2]*keep)
                avg_blue = avg_blue + avg_vals[k][3] + (numbers[i][f][3]*keep)
            end
            avg_red = avg_red/#avg_vals
            avg_green = avg_green/#avg_vals
            avg_blue = avg_blue/#avg_vals
            ret[i][f] = {avg_red, avg_green, avg_blue}
        end
    end

    return ret
end

local final_buff = processBlur(numbers)

function love.update(dt)
    if love.keyboard.isDown("w") then
        final_buff = processBlur(final_buff)
    end
end

function love.draw()
    for i = 1, Xdim, 1 do
        for f = 1, Ydim, 1 do
            love.graphics.setColor(final_buff[i][f])
            love.graphics.points(i, f)
        end
    end
end

