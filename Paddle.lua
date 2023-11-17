Paddle = Class {}

--[[
  The `init` function on our class is called just once, when the object
  is first created. Used to set up all variables in the class and get it
  ready for use.

  Our Paddle should take an X and a Y, for positioning, as well as a width
  and height for its dimensions.

  Note that `self` is a reference to *this* object, whichever object is
  instantiated at the time this function is called. Different objects can
  have their own x, y, width, and height values, thus serving as containers
  for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.dy = 0
end

--[[
  To be called by our main function in `love.update`, ideally. Right now
  this just updates the Y value based on the player's keyboard input. Later
  we'll want to put in some more interesting logic.

  @param dt The time since the last frame, in seconds. Also known as
  "deltaTime", it is LÖVE2D's way of normalizing how fast things update.
]]
function Paddle:update(dt)
  -- we use math.max to ensure that we don't go any farther than the top of the screen
  if self.dy < 0 then
    self.y = math.max(0, self.y + self.dy * dt)
    -- we use math.min to ensure we don't go any farther than the bottom of the screen
    -- minus the paddle's height (or else it will go partially below, since position is
    -- based on its top left corner)
  else
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
  end
end

--[[
  To be called by our main function in `love.draw`, ideally. Uses
  LÖVE2D's `rectangle` function, which takes in a draw mode as the first
  argument as well as the position and dimensions for the rectangle. To
  change the color, one must call `love.graphics.setColor`.
]]
function Paddle:render()
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
