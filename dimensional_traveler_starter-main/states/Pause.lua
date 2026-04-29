Pause = {}

function Pause:enter(playState)
    self.playState = playState
end

function Pause:keypressed(key)
    if key == 'p' or key == 'escape' then
        Gamestate.switch(self.playState)
    end
end

function Pause:update(dt)
end

function Pause:draw()
    self.playState:draw()

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
end