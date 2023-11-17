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

local windowWidth, windowHeight, smallFont, scoreFont, player1Score, player2Score, player1Y, player2Y, ballX, ballY, ballDX, ballDY, gameState

--[[
  Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
  love.graphics.setDefaultFilter('nearest', 'nearest')

  windowWidth, windowHeight = love.window.getDesktopDimensions()

  -- initialize our virtual resolution, which will be rendered within our actual window no matter its dimensions
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, windowWidth, windowHeight, {
    fullscreen = true,
    resizable = true,
    vsync = true
  })

  -- more "retro-looking" font object we can use for any text
  smallFont = love.graphics.newFont('font.ttf', 8)

  -- set LÖVE2D's active font to the smallFont obect
  love.graphics.setFont(smallFont)

  -- larger font for drawing the score on the screen
  scoreFont = love.graphics.newFont('font.ttf', 32)

  -- initialize score variables, used for rendering on the screen and keeping track of the winner
  player1Score = 0
  player2Score = 0

  -- paddle positions on the Y axis (they can only move up or down)
  player1Y = 30
  player2Y = VIRTUAL_HEIGHT - 50

  -- velocity and position variables for our ball when play starts
  ballX = VIRTUAL_WIDTH / 2 - 2
  ballY = VIRTUAL_HEIGHT / 2 - 2

  -- math.random returns a random value between the left and right number
  ballDX = math.random(2) == 1 and 100 or -100
  ballDY = math.random(-50, 50)

  -- game state variable used to transition between different parts of the game
  -- (used for beginning, menus, main game, high score list, etc.)
  gameState = 'start'
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
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'play'
    else
      gameState = 'start'

      -- start ball's position in the middle of the screen
      ballX = VIRTUAL_WIDTH / 2 - 2
      ballY = VIRTUAL_HEIGHT / 2 - 2

      -- given ball's x and y velocity a random starting value
      -- the and/or pattern here is Lua's way of accomplishing a ternary operation
      -- in other programming languages like C
      ballDX = math.random(2) == 1 and 100 or -100
      ballDY = math.random(-50, 50) * 1.5
    end
  end
end

--[[
  Runs every frame, with "dt" passed in, our delta in seconds
  since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
  -- player 1 movement
  if love.keyboard.isDown('w') then
    -- add negative paddle speed to current Y scaled by deltaTime
    -- now, we clamp our position between the bounds of the screen
    -- math.max returns the greater of two values; 0 and player Y
    -- will ensure we don't go above it
    player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown('s') then
    -- add positive paddle speed to current Y scaled by deltaTime
    -- math.min returns the lesser of two values; bottom of the egde minus paddle height
    -- and player Y will ensure we don't go below it
    player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
  end

  -- player 2 movement
  if love.keyboard.isDown('up') then
    -- add negative paddle speed to current Y scaled by deltaTime
    player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
  elseif love.keyboard.isDown('down') then
    -- add positive paddle speed to current Y scaled by deltaTime
    player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
  end

  -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent
  if gameState == 'play' then
    ballX = ballX + ballDX * dt
    ballY = ballY + ballDY * dt
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
  love.graphics.printf(gameState:sub(1, 1):upper() .. gameState:sub(2), 0, 20, VIRTUAL_WIDTH, 'center')

  -- draw score on the left and right center of the screen
  -- need to switch font to draw before actually printing
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  -- render first paddle (left side)
  love.graphics.rectangle('fill', 10, player1Y, 5, 20)

  -- render second paddle (right side)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

  -- render ball (center)
  love.graphics.rectangle('fill', ballX, ballY, 4, 4)

  -- end rendering at virtual resolution
  push:apply('end')
end
