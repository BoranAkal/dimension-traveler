push = require 'lib.push'
Gamestate = require 'lib.hump.gamestate'

require 'states.Menu'
require 'states.Play'
require 'states.Pause'
require 'states.Win'
require 'states.GameOver'
require 'states.HighScore'
require 'objects.Player'
require 'objects.Bullet'
require 'objects.Enemy'
require 'objects.Boss'
require 'states.Transition'

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

currentRunScore = 0

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('The Dimensional Traveler')

    gFonts = {
        small = love.graphics.newFont(8),
        medium = love.graphics.newFont(16),
        large = love.graphics.newFont(32)
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    goToState(Menu)
end

function goToState(state, ...)
    Gamestate.switch(Transition, state, ...)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.draw()
    push:start()
        Gamestate.draw()
    push:finish()
end

function love.quit()
    if currentRunScore and currentRunScore > 0 then
        HighScore.addScore(currentRunScore)
    end
end