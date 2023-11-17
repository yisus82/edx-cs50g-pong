Ball = Class {}

--[[
  The init function on our class is called just once, when the object is first
  created. Used to set up all variables in the class and get it ready for use.

  Our Ball should take an X and a Y, for positioning, as well as a width
  and height for its dimensions.

  Note that `self` is a reference to *this* object, whichever object is
  instantiated at the time this function is called. Different objects can
  have their own x, y, width, and height values, thus serving as containers
  for data. In this sense, they're very similar to structs in C.

  @param x The starting X coordinate of the ball.
  @param y The starting Y coordinate of the ball.
  @param width The width of the ball.
  @param height The height of the ball.
]]
function Ball:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dy = math.random(2) == 1 and -100 or 100
  self.dx = math.random(-50, 50)
end

--[[
  Places the ball in the middle of the screen, with an initial random velocity
  on both axes.
]]
function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dy = math.random(2) == 1 and -100 or 100
  self.dx = math.random(-50, 50)
end

--[[
  Simply applies velocity to position, scaled by deltaTime.
  @param dt The time since the last frame, in seconds. Also known as
  "deltaTime", it is LÖVE2D's way of normalizing how fast things update.
]]
function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

--[[
  Renders the ball.
]]
function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
