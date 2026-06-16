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

    local bias = nil

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
                local function moveRandom()
                    local r
                    if bias and love.math.random(1, 10)/10 < 0.7 then
                        r = bias
                    else
                        r = love.math.random(1, 4)
                    end
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

                    return r
                end

                local oldX = x
                local oldY = y
                local oldDist = dist()
                local movesel = moveRandom()
                local newDist = dist()

                dots[#dots + 1] = {x, y}

                if newDist>oldDist then --? was this a good move?
                    --x = oldX
                    --y = oldY
                    dots[#dots].good = false
                else
                    dots[#dots].good = true
                    bias = movesel
                end

                if newDist < 20 then
                    instanceNO = instanceNO + 1
                    print("Instance: ", instanceNO)
                    foodParticle.newPOS()
                end
                if instanceNO == finalInstance then
                    love.event.quit()
                end
            end
        },

        getData = function()
            return dots
        end
    })
end

local foodParticle = food()
foodParticle.newPOS()
local agentInstance = agent(foodParticle, 20)

guified.registry.register(foodParticle)
guified.registry.register(agentInstance)

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
    print("Correct rate", (good/total)*100, "%")

    guified.extcalls.quit()
end
