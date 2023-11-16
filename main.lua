--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.window.setMode(0, 0, {
        fullscreen = true,
        resizable = true,
        vsync = true
    })
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
    local width, height, _ = love.window.getMode()
    love.graphics.printf(
        'Hello Pong!',  -- text to render
        0,              -- starting X (0 since we're going to center it based on width)
        height / 2 - 6, -- starting Y (halfway down the screen, the default font size is 12)
        width,          -- number of pixels to center within (the entire screen here)
        'center')       -- alignment mode, can be 'center', 'left', or 'right'
end

--[[
    Called whenever a key is pressed.
    @param key The key that was pressed.
    @param scancode The scancode of the key that was pressed.
    @param isrepeat Whether this keypress event is a repeat. The delay between key repeats
    depends on the user's system settings.
]]
function love.keypressed(key, _, _)
    if key == "escape" then
        love.event.quit()
    end
end
