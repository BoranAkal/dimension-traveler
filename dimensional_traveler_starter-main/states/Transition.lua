Transition = {}

local nextState
local nextArgs

local alpha = 0
local state = "fadeOut"

local fadeSpeed = 1.5

function Transition:enter(newState, ...)
    nextState = newState
    nextArgs = {...}

    alpha = 0
    state = "fadeOut"
end

function Transition:update(dt)

    if state == "fadeOut" then

        -- smooth fade out
        alpha = alpha + fadeSpeed * dt

        if alpha >= 1 then
            alpha = 1

            local target = nextState
            local args = nextArgs

            nextState = nil
            nextArgs = nil

            -- switch AFTER full fade
            Gamestate.switch(target, unpack(args))
        end
    end
end

function Transition:draw()

    love.graphics.setColor(0.05, 0.05, 0.08, alpha * 0.85)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(1, 1, 1)
end

return Transition