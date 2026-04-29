Bullet = {}
Bullet.__index = Bullet

function Bullet.create(x, y, dir, owner)
    local self = setmetatable({}, Bullet)

    self.x = x
    self.y = y
    self.dx = 240 * dir
    self.width = 4
    self.height = 4
    self.dead = false
    self.owner = owner   -- "player" or "enemy"
    self.startX = x
    self.range = 250

    return self
end

function Bullet:update(dt)
    self.x = self.x + self.dx * dt

    -- range limit (distance traveled)
    if math.abs(self.x - self.startX) > self.range then
        self.dead = true
    end

    -- safety fallback (out of world)
    if self.x < -50 or self.x > 2050 then
        self.dead = true
    end
end

function Bullet:draw()

    if self.owner == "player" then
        love.graphics.setColor(0.2, 0.6, 1)
    elseif self.owner == "enemy" then
        love.graphics.setColor(1, 0.2, 0.2)

    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1)
end
return Bullet