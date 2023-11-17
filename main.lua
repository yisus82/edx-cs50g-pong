--[[
  push is a library that will allow us to draw our game at a virtual
  resolution, instead of however large our window is; used to provide
  a more retro aesthetic

  https://github.com/Ulydev/push
]]
local push = require 'push'

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

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

  -- more "retro-looking" font object we can use for any text
  local smallFont = love.graphics.newFont('font.ttf', 8)

  -- set LÖVE2D's active font to the smallFont obect
  love.graphics.setFont(smallFont)

  -- larger font for drawing the score on the screen
  ScoreFont = love.graphics.newFont('font.ttf', 32)

  -- initialize score variables, used for rendering on the screen and keeping track of the winner
  Player1Score = 0
  Player2Score = 0

  -- paddle positions on the Y axis (they can only move up or down)
  Player1Y = 30
  Player2Y = VIRTUAL_HEIGHT - 50
end

--[[
  Runs every frame, with "dt" passed in, our delta in seconds
  since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
  -- player 1 movement
  if love.keyboard.isDown('w') then
    -- add negative paddle speed to current Y scaled by deltaTime
    Player1Y = Player1Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown('s') then
    -- add positive paddle speed to current Y scaled by deltaTime
    Player1Y = Player1Y + PADDLE_SPEED * dt
  end

  -- player 2 movement
  if love.keyboard.isDown('up') then
    -- add negative paddle speed to current Y scaled by deltaTime
    Player2Y = Player2Y + -PADDLE_SPEED * dt
  elseif love.keyboard.isDown('down') then
    -- add positive paddle speed to current Y scaled by deltaTime
    Player2Y = Player2Y + PADDLE_SPEED * dt
  end
end

--[[
  Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  -- begin rendering at virtual resolution
  push:apply('start')

  -- clear the screen with a color similar to some versions of the original Pong
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

  -- draw welcome text toward the top of the screen
  love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

  -- draw score on the left and right center of the screen
  -- need to switch font to draw before actually printing
  love.graphics.setFont(ScoreFont)
  love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- render first paddle (left side)
  love.graphics.rectangle('fill', 10, Player1Y, 5, 20)

  -- render second paddle (right side)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, Player2Y, 5, 20)

  -- render ball (center)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

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
