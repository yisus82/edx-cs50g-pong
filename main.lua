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

local windowWidth, windowHeight, smallFont, largeFont, scoreFont, player1Score, player2Score, player1, player2, ball, gameState, servingPlayer, winningPlayer

--[[
  Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text and graphics
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- set the title of our application window
  love.window.setTitle('Pong')

  -- "seed" the RNG so that calls to random are always random
  -- use the current time, since that will vary on startup every time
  math.randomseed(os.time())

  windowWidth, windowHeight = love.window.getDesktopDimensions()

  -- initialize our virtual resolution, which will be rendered within our actual window no matter its dimensions
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  -- initialize our nice-looking retro text fonts
  smallFont = love.graphics.newFont('font.ttf', 8)
  largeFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 32)
  love.graphics.setFont(smallFont)

  -- initialize score variables, used for rendering on the screen and keeping track of the winner
  player1Score = 0
  player2Score = 0

  -- initialize the serving player; the player whose turn it is to serve will serve first
  servingPlayer = 1

  -- initialize the player who won the game; obviously, no one has won yet
  winningPlayer = 0

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
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
    elseif gameState == 'done' then
      gameState = 'serve'
      ball:reset()
      player1Score = 0
      player2Score = 0
      -- decide serving player as the opposite of who won
      if winningPlayer == 1 then
        servingPlayer = 2
      else
        servingPlayer = 1
      end
      winningPlayer = 0
    end
  elseif key == "f" then
    push:switchFullscreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
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

  -- if we are in serve state, we need to set the ball's velocity and direction
  if gameState == 'serve' then
    -- before switching to play, initialize ball's velocity based
    -- on player who last scored
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
    -- update positions based on velocity scaled by deltaTime
    player1:update(dt)
    player2:update(dt)
    -- if we are in play state, check collisions and update positions based on velocity scaled by deltaTime
  elseif gameState == 'play' then
    -- detect ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position of collision
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end

    -- detect upper and lower screen boundary collision and reverse if collided
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
    end

    -- -4 to account for the ball's size
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
    end

    -- if we reach the left or right edge of the screen,
    -- reset ball, change state to serve, set servingPlayer and update the score
    if ball.x < 0 then
      player2Score = player2Score + 1
      ball:reset()
      gameState = 'serve'
      servingPlayer = 1

      -- if we've reached a score of 10, the game is over; we set the
      -- state to done so we can show the victory message
      if player2Score == 10 then
        winningPlayer = 2
        gameState = 'done'
      end
    end

    if ball.x > VIRTUAL_WIDTH then
      player1Score = player1Score + 1
      ball:reset()
      gameState = 'serve'
      servingPlayer = 2

      -- if we've reached a score of 10, the game is over; we set the
      -- state to done so we can show the victory message
      if player1Score == 10 then
        winningPlayer = 1
        gameState = 'done'
      end
    end

    -- update positions based on velocity scaled by deltaTime
    ball:update(dt)
    player1:update(dt)
    player2:update(dt)

    -- set the title of our application window
    love.window.setTitle('Pong - FPS: ' .. tostring(love.timer.getFPS()))
  else
    love.window.setTitle('Pong')
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

  -- draw different UI messages based on the state of the game
  if gameState == 'start' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
      0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'done' then
    love.graphics.setFont(largeFont)
    love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
  end

  -- draw score; we need to switch the font to use before actually printing
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), 50, 10)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH - 50, 10)

  -- render objects into the screen
  player1:render()
  player2:render()
  ball:render()

  -- end rendering at virtual resolution
  push:apply('end')
end
