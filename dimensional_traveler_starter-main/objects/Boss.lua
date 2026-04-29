Boss = {}
Boss.__index = Boss

function Boss.create(x, y)
    local self = setmetatable({}, Boss)
    self.x = x
    self.y = y
    self.width = 36
    self.height = 40
    self.health = 10
    self.phase = 1
    self.speed = 30
    self.fireTimer = 0
    self.fireRate = 3
    self.maxHealth = self.health
    return self
end

function Boss:update(dt, player, bullets)
    self:checkPhase()

    self:movePattern(dt, player)

    -- fire timer
    self.fireTimer = self.fireTimer + dt

    if self.phase == 1 then
        if self.fireTimer >= self.fireRate then
            self.fireTimer = 0

            table.insert(bullets, Bullet.create(
                self.x,
                self.y + self.height / 2,
                (player.x < self.x) and -1 or 1,
                "enemy"
            ))
        end
    elseif self.phase == 2 then
        if self.fireTimer >= self.fireRate then
            self.fireTimer = 0
            self:fireSpread(bullets, player)
        end
    end
end

function Boss:checkPhase()
    if self.health <= self.maxHealth / 2 then
        self.phase = 2
        self.fireRate = 1.5
        self.speed = 60
    end
end

function Boss:movePattern(dt, player)
    -- patrol movement
    self.x = self.x + self.speed * dt

    if self.x <= 300 then
        self.x = 300
        self.speed = math.abs(self.speed)
    elseif self.x >= 1500 then
        self.x = 1500
        self.speed = -math.abs(self.speed)
    end

    self.campTimer = (self.campTimer or 0) - dt

    local dist = math.abs(player.x - self.x)

    if dist < 90 and self.campTimer <= 0 then
        self.x = self.x + (self.x < player.x and -120 or 120)
        self.campTimer = 1.5
    end
end

function Boss:fireSpread(bullets, player)
    local dir = (player.x < self.x) and -1 or 1

    table.insert(bullets, Bullet.create(self.x, self.y + self.height / 2, dir, "enemy"))
    table.insert(bullets, Bullet.create(self.x, self.y + self.height / 2 - 10, dir, "enemy"))
    table.insert(bullets, Bullet.create(self.x, self.y + self.height / 2 + 10, dir, "enemy"))
end

function Boss:draw()
    love.graphics.setColor(0.7, 0.2, 0.9)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

return Boss