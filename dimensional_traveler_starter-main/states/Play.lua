Play = {}

function Play:enter(previous)
    self.zoom = 1
    self.cameraX = self.cameraX or 0
    self.worldWidth = 2000
    self.groundY = 200
    if not self.player then
        self.player = Player.create(0, self.groundY)
    end
    if not self.initialized then
        self.bullets = {}

        self.enemies = {
            Enemy.create(400, self.groundY),
            Enemy.create(800, self.groundY),
            Enemy.create(1200, self.groundY)
        }
        self.boss = Boss.create(1600, self.groundY)

        self.backgrounds = {
            love.graphics.newImage("assets/sprites/bg_layer1/orig.png"),
            love.graphics.newImage("assets/sprites/bg_layer2/orig.png"),
            love.graphics.newImage("assets/sprites/bg_layer3/orig.png")
        }
        self.level = 1
        self.initialized = true
    end
end

function Play:keypressed(key)
    if key == 'p' then
       goToState(Pause, self)
    elseif key == 'escape' then
        HighScore.addScore(self.player.score)
        goToState(Menu)

    elseif key == 'space' then
        table.insert(self.bullets, Bullet.create(
            self.player.x + self.player.width,
            self.player.y + self.player.height / 2,
            1,
            "player"
        ))
    end
end

function Play:update(dt)
    self.player:update(dt)

      for _, enemy in ipairs(self.enemies) do
    if not enemy.dead then

        if self.player.x < enemy.x + enemy.width and
           self.player.x + self.player.width > enemy.x and
           self.player.y < enemy.y + enemy.height and
           self.player.y + self.player.currentHitboxHeight > enemy.y then

            -- push player out to the left or right
            local overlapLeft = (self.player.x + self.player.width) - enemy.x
            local overlapRight = (enemy.x + enemy.width) - self.player.x

            if overlapLeft < overlapRight then
                self.player.x = self.player.x - overlapLeft
            else
                self.player.x = self.player.x + overlapRight
            end
        end
    end
   end

    -- switch levels for debug stufff
    if love.keyboard.isDown("1") then self.level = 1 end
    if love.keyboard.isDown("2") then self.level = 2 end
    if love.keyboard.isDown("3") then self.level = 3 end

    -- camera folllow
    local leftMargin = 60
    local targetX = self.player.x - leftMargin

    self.cameraX = self.cameraX + (targetX - self.cameraX) * 5 * dt

    -- cam stop at limit
    self.cameraX = math.max(0, math.min(self.cameraX, self.worldWidth - VIRTUAL_WIDTH))

    -- bullets update
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt)

        -- player bullet to enemies
        if bullet.owner == "player" then
            for _, enemy in ipairs(self.enemies) do
                if not enemy.dead and (enemy.hitCooldown or 0) <= 0 then
                    if bullet.x < enemy.x + enemy.width and
                       bullet.x + bullet.width > enemy.x and
                       bullet.y < enemy.y + enemy.height and
                       bullet.y + bullet.height > enemy.y then

                        enemy:takeDamage()
                        enemy.hitCooldown = 0.1
                        bullet.dead = true
                        self.player.score = self.player.score + 10
                    end
                end
            end
        end

        -- enemy bullet to player
        -- boss hit
         if bullet.owner == "player" and not self.boss.dead then
         if bullet.x < self.boss.x + self.boss.width and
          bullet.x + bullet.width > self.boss.x and
          bullet.y < self.boss.y + self.boss.height and
          bullet.y + bullet.height > self.boss.y then

          self.boss.health = self.boss.health - 1
          bullet.dead = true

          if self.boss.health <= 0 then
             self.boss.dead = true
         end
     end
 end

        if bullet.dead then
            table.remove(self.bullets, i)
        end
    end

    -- remove corpses
    for i = #self.enemies, 1, -1 do
        if self.enemies[i].dead then
            table.remove(self.enemies, i)
        end
    end

    -- enemy updates
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, self.player, self.bullets)
    end

    -- boss update
    self.boss:update(dt, self.player, self.bullets)

    -- win con
    if self.boss.health <= 0 then
        Gamestate.switch(Win, self.player.score)
    end
end

function Play:draw()
    love.graphics.clear(0.1, 0.12, 0.18)

    local bg = self.backgrounds[self.level]

    if bg then
        local bgWidth = bg:getWidth()
        -- align bottom of background
        local bgY = VIRTUAL_HEIGHT - bg:getHeight()
        -- repeat background across world
        for x = 0, self.worldWidth, bgWidth do
            love.graphics.draw(bg, x - self.cameraX * 0.2, bgY)
        end
    end

    love.graphics.push()
    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.translate(-self.cameraX, 0)
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
    self.boss:draw()
    self.player:draw()
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    love.graphics.pop()

    self:drawHUD()
end

function Play:drawHUD()
    love.graphics.setFont(gFonts.small)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 5, 5, 75, 50)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 10, 10, 60, 6)
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.rectangle("fill", 10, 10, self.player.healthLevel * 12, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Lives: " .. self.player.lives, 10, 22)
    love.graphics.print("Score: " .. self.player.score, 10, 36)
end