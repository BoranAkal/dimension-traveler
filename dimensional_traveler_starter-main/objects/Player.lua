Player = {}
Player.__index = Player

function Player.create(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 16
    self.height = 32
    self.healthLevel = 5
    self.lives = 3
    self.score = 0
    self.startX = x
    self.startY = y
    self.isCrouching = false
    self.currentHitboxHeight = self.height
    self.invincible = false
    self.invincibleTimer = 0
    self.flashTimer = 0
    self.showSprite = true
    return self
end

function Player:update(dt)
    local speed = 90

    -- movement
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - speed * dt
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + speed * dt
    end

    -- sync score
    currentRunScore = self.score

    -- invincibility timers
    if self.invincible then
        self.invincibleTimer = self.invincibleTimer - dt
        self.flashTimer = self.flashTimer - dt

        if self.flashTimer <= 0 then
            self.flashTimer = 0.1
            self.showSprite = not self.showSprite
        end

        if self.invincibleTimer <= 0 then
            self.invincible = false
            self.showSprite = true
        end
    end

    -- crouch
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.isCrouching = true
        self.currentHitboxHeight = self.height / 2
    else
        self.isCrouching = false
        self.currentHitboxHeight = self.height
    end

    -- world boundries
    local maxX = 2000 - self.width
    self.x = math.max(0, math.min(maxX, self.x))
end

function Player:takeDamage()
    if self.invincible then return end

    self.healthLevel = self.healthLevel - 1

    -- Grace when life lost
    if self.healthLevel <= 0 then
        self.lives = self.lives - 1

        if self.lives > 0 then
            self.healthLevel = 5

            -- GRACE PERIOD ONLY HERE
            self.invincible = true
            self.invincibleTimer = 2
            self.flashTimer = 0.1
            self.showSprite = true
        else
            goToState(GameOver)
        end
    end
end

function Player:draw()
    if self.invincible and not self.showSprite then
        love.graphics.setColor(0.4, 0.7, 1)
    else
        love.graphics.setColor(0.5, 0.8, 1)
    end

    if self.isCrouching then
        love.graphics.rectangle(
            "fill",
            self.x,
            self.y + self.height / 2,
            self.width,
            self.height / 2
        )
    else
        love.graphics.rectangle(
            "fill",
            self.x,
            self.y,
            self.width,
            self.height
        )
    end

    love.graphics.setColor(1, 1, 1)
end

return Player