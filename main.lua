--[[
  push is a library that will allow us to draw our game at a virtual
  resolution, instead of however large our window is; used to provide
  a more retro aesthetic

  https://github.com/Ulydev/push
]]
local push = require 'push'

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--[[
  Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
  love.graphics.setDefaultFilter('nearest', 'nearest')

  local windowWidth, windowHeight = love.window.getDesktopDimensions()

  -- initialize our virtual resolution, which will be rendered within our actual window no matter its dimensions
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, windowWidth, windowHeight, {
    fullscreen = true,
    resizable = true,
    vsync = true
  })
end

--[[
  Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  -- begin rendering at virtual resolution
  push:apply('start')

  love.graphics.printf(
    'Hello Pong!',          -- text to render
    0,                      -- starting X (0 since we're going to center it based on width)
    VIRTUAL_HEIGHT / 2 - 6, -- starting Y (halfway down the screen, the default font size is 12)
    VIRTUAL_WIDTH,          -- number of pixels to center within (the entire screen here)
    'center')               -- alignment mode, can be 'center', 'left', or 'right'

  -- end rendering at virtual resolution
  push:apply('end')
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
