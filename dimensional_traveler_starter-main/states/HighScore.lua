HighScore = {}

local HIGH_SCORE_FILE = "highscores.txt"

-- state enter (for HighScore screen)
function HighScore:enter()
    self.scores = HighScore.loadScores()
end

function HighScore.getHighestScore()
    local scores = HighScore.loadScores()

    local highest = 0
    for i = 1, #scores do
        if scores[i] > highest then
            highest = scores[i]
        end
    end

    return highest
end

function HighScore:keypressed(key)
    if key == "escape" or key == "return" or key == "enter" then
        goToState(Menu)
    end
end

function HighScore:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    love.graphics.setFont(gFonts.large)
    love.graphics.printf("High Scores", 0, 20, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(gFonts.medium)

    for i = 1, 3 do
        local score = self.scores[i] or 0
        love.graphics.printf(i .. ". " .. score, 0, 70 + i * 22, VIRTUAL_WIDTH, "center")
    end

    love.graphics.setFont(gFonts.small)
    love.graphics.printf("Press Enter or Escape to return", 0, VIRTUAL_HEIGHT - 24, VIRTUAL_WIDTH, "center")
end

-- load
function HighScore.loadScores()
    local scores = {}

    if love.filesystem.getInfo(HIGH_SCORE_FILE) then
        for line in love.filesystem.lines(HIGH_SCORE_FILE) do
            local n = tonumber(line)
            if n then
                table.insert(scores, n)
            end
        end
    end

    table.sort(scores, function(a, b)
        return a > b
    end)

    while #scores < 3 do
        table.insert(scores, 0)
    end

    return scores
end

-- save
function HighScore.saveScores(scores)
    table.sort(scores, function(a, b)
        return a > b
    end)

    while #scores > 3 do
        table.remove(scores)
    end

    local data = ""
    for i = 1, #scores do
        data = data .. scores[i] .. "\n"
    end

    love.filesystem.write(HIGH_SCORE_FILE, data)
end

function HighScore.addScore(newScore)
    local scores = HighScore.loadScores()

    table.insert(scores, newScore)

    table.sort(scores, function(a, b)
        return a > b
    end)

    while #scores > 3 do
        table.remove(scores)
    end

    HighScore.saveScores(scores)
end

return HighScore