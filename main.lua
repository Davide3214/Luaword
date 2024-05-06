function love.load()
    
    wf = require 'Libraries/windfield'

    World = wf.newWorld(0, 0)

    camera = require 'Libraries/camera'
    cam = camera()
    
    anim8 = require 'Libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'Libraries/sti'
    gamemap = sti('Maps/Map.lua')

    love.window.setMode(500, 500)
    love.window.setTitle("Luaword")

    player = {}
    player_collider = World:newBSGRectangleCollider(400, 250, 35, 55, 1)
    player_collider:setFixedRotation(true)
    player_x = 168
    player_y = 136
    velocity = 180
    player_spritesheet = love.graphics.newImage('Sprites/Player_sheet.png')
    walls = {}
    if gamemap.layers["Walls"] then
        for i, obj in pairs(gamemap.layers["Walls"].objects) do
            local wall = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end
    player_grid = anim8.newGrid( 32, 64, player_spritesheet:getWidth(), player_spritesheet:getHeight() )
    player_animations = {}
    player_animations_down = anim8.newAnimation( player_grid('1-4', 1), 0.2 )
    player_animations_up = anim8.newAnimation( player_grid('1-4', 2), 0.2 )
    player_animations_left = anim8.newAnimation( player_grid('1-4', 3), 0.2 )
    player_animations_right = anim8.newAnimation( player_grid('1-4', 4), 0.2 )

    player_anim = player_animations_left

    
end 

function love.update(dt)
    local Ismoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("down") then
        vy= velocity
        player_anim = player_animations_down
        Ismoving = true
    end
    if love.keyboard.isDown("up") then
        vy = velocity * -1
        player_anim = player_animations_up
        Ismoving = true
    end
    if love.keyboard.isDown("left") then
        vx = velocity * -1
        player_anim = player_animations_left
        Ismoving = true
    end
    if love.keyboard.isDown("right") then
        vx = velocity
        player_anim = player_animations_right
        Ismoving = true
    end

    player_collider:setLinearVelocity(vx, vy)

    if Ismoving == false then
        player_anim:gotoFrame(2)
    end

    World:update(dt)
    player_x = player_collider:getX()
    player_y = player_collider:getY()

    player_anim:update(dt)

    cam:lookAt(player_x, player_y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if  cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gamemap.width * gamemap.tilewidth
    local mapH = gamemap.height * gamemap.tileheight

    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.draw()
    cam:attach()
        gamemap:drawLayer(gamemap.layers["Terreno"])
        gamemap:drawLayer(gamemap.layers["Alberi"])
        gamemap:drawLayer(gamemap.layers["Portale"])
        player_anim:draw(player_spritesheet, player_x, player_y, nil, 1, nil, 16, 32)
    cam:detach()
    
end