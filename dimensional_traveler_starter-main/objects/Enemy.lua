Enemy = {}
Enemy.__index = Enemy

function Enemy.create(x, y)
    local self = setmetatable({}, Enemy)

    self.x = x
    self.y = y
    self.width = 16
    self.height = 28
    self.speed = 40
    self.health = 3
    self.hitFlashTimer = 0
    self.hitCooldown = 0
    self.dead = false
    self.fireCooldown = math.random(2.5, 3.5)
    self.isBursting = false
    self.burstCount = 0
    self.maxBurst = 0
    self.burstTimer = 0

    return self
end

function Enemy:update(dt, player, bullets)

    -- cooldown for damage
    if self.hitCooldown > 0 then
        self.hitCooldown = self.hitCooldown - dt
    end

    -- hit flash timer
    if self.hitFlashTimer > 0 then
        self.hitFlashTimer = self.hitFlashTimer - dt
    end

    -- burst logic
    if not self.isBursting then
        self.fireCooldown = self.fireCooldown - dt

        if self.fireCooldown <= 0 and self:canSeePlayer(player) then
            self.isBursting = true
            self.maxBurst = math.random(2, 4)
            self.burstCount = 0
            self.burstTimer = 0
        end
    else
        self.burstTimer = self.burstTimer - dt

        if self.burstTimer <= 0 then

            local dir = (player.x < self.x) and -1 or 1

            table.insert(bullets, Bullet.create(
                self.x,
                self.y + self.height / 2,
                dir,
                "enemy"
            ))

            self.burstCount = self.burstCount + 1
            self.burstTimer = 0.25

            if self.burstCount >= self.maxBurst then
                self.isBursting = false
                self.fireCooldown = math.random(1.5, 3.5)
            end
        end
    end
end

function Enemy:canSeePlayer(player)
    return math.abs(player.x - self.x) < 300
end

function Enemy:draw()

    if self.hitFlashTimer > 0 then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 0.4, 0.4)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1)
end

function Enemy:takeDamage()
    if self.hitCooldown > 0 then return end

    self.health = self.health - 1
    self.hitFlashTimer = 0.15
    self.hitCooldown = 0.1

    if self.health <= 0 then
        self.dead = true
    end
end

return Enemy