local guified = require("libs.guified.init")
---@type Color
local colors = require("libs.guified.modules.colors")
local logger = guified.debug.logger

local function food()
    local x = 0
    local y = 0
    return({
        _guified = {
            name = "food",
            draw = function()
                love.graphics.setColor(colors.orange)
                love.graphics.circle("fill", x, y, 20)
            end
        },

        newPOS = function()
            x = love.math.random(0, love.graphics.getWidth())
            y = love.math.random(0, love.graphics.getHeight())
        end,

        getPOS = function()
            return x, y
        end
    })
end

local function agent(foodParticle, finalInstance)
    local x = love.math.random(0, love.graphics.getWidth())
    local y = love.math.random(0, love.graphics.getHeight())

    local bias = {
        left = {0, 0, 0, 0},
        right = {0, 0, 0, 0},
        up = {0, 0, 0, 0},
        down = {0, 0, 0, 0}
    }

    local dots = {}

    local instanceNO = 0

    return({
        _guified = {
            name = "agent",
            draw = function()
                love.graphics.setColor(colors.blue)
                love.graphics.rectangle("fill", x, y, 20, 20)

                for i = 1, #dots, 1 do
                    if dots[i].good then
                        love.graphics.setColor(colors.green)
                    else
                        love.graphics.setColor(colors.red)
                    end
                    love.graphics.points(dots[i])
                end
            end,

            update = function()
                local function dist()
                    local foodX, foodY = foodParticle.getPOS()
                    return(math.sqrt(((foodX-x)^2) + ((foodY-y)^2)))
                end
                local function move()
                    local function pickMove()
                        local foodX, foodY = foodParticle.getPOS()
                        local direction
                        if foodX > x then
                            direction = "right"
                        end
                        if foodX < x then
                            direction = "left"
                        end
                        if foodY > y then
                            direction = "down"
                        end
                        if foodY < y then
                            direction = "up"
                        end

                        local weights = {}
                        local total = 0

                        for i = 1, 4 do
                            weights[i] = math.max(0, bias[direction][i])
                            total = total + weights[i]
                        end

                        if total == 0 then
                            return love.math.random(1, 4), direction
                        end

                        local r = love.math.random() * total
                        local sum = 0

                        for i = 1, 4 do
                            sum = sum + weights[i]
                            if r <= sum then
                                return i, direction
                            end
                        end
                    end
                    local r, direction = pickMove()
                    --bias = r
                    if r == 1 then
                        x = x + 1
                    end
                    if r == 2 then
                        x = x - 1
                    end
                    if r == 3 then
                        y = y + 1
                    end
                    if r == 4 then
                        y = y - 1
                    end

                    return r, direction
                end

                local oldX = x
                local oldY = y
                local oldDist = dist()
                local movesel, direction = move()
                local newDist = dist()

                dots[#dots + 1] = {x, y}

                if newDist>oldDist then --? was this a good move?
                    --x = oldX
                    --y = oldY
                    dots[#dots].good = false
                    bias[direction][movesel] = bias[direction][movesel] - 2
                    bias[direction][movesel] = math.max(-20, math.min(20, bias[direction][movesel]))
                else
                    dots[#dots].good = true
                    bias[direction][movesel] = bias[direction][movesel] + 1
                end

                if newDist < 20 then
                    instanceNO = instanceNO + 1
                    print("Instance: ", instanceNO)
                    foodParticle.newPOS()
                    for i = 1, 4 do
                        bias[direction][i] = bias[direction][i] * 1.1
                    end
                end
                if instanceNO == finalInstance then
                    love.event.quit()
                end
            end
        },

        getData = function()
            return dots
        end,

        setData = function(argdata)
            dots = argdata
        end,

        getPOS = function()
            return x, y
        end,

        getBias = function()
            return bias
        end,

        setBias = function(argbias)
            bias = argbias
        end
    })
end

local INSTANCES = 30

local foodParticle = food()
foodParticle.newPOS()
local agentInstance = agent(foodParticle, INSTANCES)

guified.registry.register(foodParticle)
guified.registry.register(agentInstance)
guified.registry.register({
    _guified = {
        name = "agent out of bounds checker",
        draw = function()
            
        end,
        update = function()
            local x, y = agentInstance.getPOS()
            if x > love.graphics.getWidth() or x < 0 or y > love.graphics.getHeight() or y < 0 then
                local bias = agentInstance.getBias()
                local data = agentInstance.getData()
                local directions = {"left", "right", "up", "down"}
                for i = 1, #directions, 1 do
                    for f = 1, 4 do
                        bias[directions[i]][f] = bias[directions[i]][f] * 0.05 -- weaken everything
                    end
                end
                guified.registry.remove(agentInstance)
                agentInstance = agent(foodParticle, INSTANCES)
                agentInstance.setBias(bias)
                agentInstance.setData(data)
                guified.registry.register(agentInstance)
            end
        end
    }
})

local successRateText = guified.elements.text("Success Rate: ", 0, 0)
guified.registry.register(successRateText)
local errorRateText = guified.elements.text("Error Rate: ", 0, 12)
guified.registry.register(errorRateText)

guified.registry.register({
    _guified = {
        name = "Stats updater",
        draw = function()
        end,
        update = function()
            local good = 0
            local bad = 0
            local total = 0

            local data = agentInstance.getData()
            for i = 1, #data, 1 do
                if data[i].good then
                    good = good + 1
                else
                    bad = bad + 1
                end
                total = total + 1
            end

            successRateText.setText("Success Rate: "..tostring((good/total)*100))
            errorRateText.setText("Error Rate: "..tostring((bad/total)*100))
        end
    }
})

function love.quit()
    local data = agentInstance.getData()
    local total = 0
    local good = 0
    local bad = 0
    for i = 1, #data, 1 do
        if data[i].good then
            good = good + 1
        else
            bad = bad + 1
        end
        total = total + 1
    end

    print("Error rate", (bad/total)*100, "%")
    print("Success rate", (good/total)*100, "%")

    guified.extcalls.quit()
end
