--[[
  push is a library that will allow us to draw our game at a virtual
  resolution, instead of however large our window is; used to provide
  a more retro aesthetic

  https://github.com/Ulydev/push
]]
local push = require 'push'

--[[
  class is a library we're using that will allow us to represent anything in our
  game as code, rather than keeping track of many disparate variables and methods

  https://github.com/vrld/hump/blob/master/class.lua
]]
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200

local windowWidth, windowHeight, smallFont, scoreFont, player1Score, player2Score, player1, player2, ball, gameState

--[[
  Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- "seed" the RNG so that calls to random are always random
  -- use the current time, since that will vary on startup every time
  math.randomseed(os.time())

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

  -- initialize our player paddles; make them global so that they can be
  -- detected by other functions and modules
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  -- place a ball in the middle of the screen
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

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
      ball:reset()
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
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  -- player 2 movement
  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end

  -- if we are in play state, update positions based on velocity scaled by deltaTime
  if gameState == 'play' then
    ball:update(dt)
    player1:update(dt)
    player2:update(dt)
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

  -- render objects into the screen
  player1:render()
  player2:render()
  ball:render()

  -- end rendering at virtual resolution
  push:apply('end')
end
