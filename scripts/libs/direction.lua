local Direction = {
  UP = "UP",
  LEFT = "LEFT",
  DOWN = "DOWN",
  RIGHT = "RIGHT",
  UP_LEFT = "UP LEFT",
  UP_RIGHT = "UP RIGHT",
  DOWN_LEFT = "DOWN LEFT",
  DOWN_RIGHT = "DOWN RIGHT",
}

local reverse_table = {
  [Direction.UP] = Direction.DOWN,
  [Direction.LEFT] = Direction.LEFT,
  [Direction.DOWN] = Direction.UP,
  [Direction.RIGHT] = Direction.LEFT,
  [Direction.UP_LEFT] = Direction.DOWN_RIGHT,
  [Direction.UP_RIGHT] = Direction.DOWN_LEFT,
  [Direction.DOWN_LEFT] = Direction.UP_RIGHT,
  [Direction.DOWN_RIGHT] = Direction.UP_LEFT,
}

function Direction.reverse(direction)
  return reverse_table[direction]
end

function Direction.from_points(point_a, point_b)
  local a_z_offset = point_a.z / 2
  local a_x = point_a.x - a_z_offset
  local a_y = point_a.y - a_z_offset

  local b_z_offset = point_b.z / 2
  local b_x = point_b.x - b_z_offset
  local b_y = point_b.y - b_z_offset

  return Direction.from_offset(b_x - a_x, b_y - a_y)
end

function Direction.diagonal_from_points(point_a, point_b)
  local a_z_offset = point_a.z / 2
  local a_x = point_a.x - a_z_offset
  local a_y = point_a.y - a_z_offset

  local b_z_offset = point_b.z / 2
  local b_x = point_b.x - b_z_offset
  local b_y = point_b.y - b_z_offset

  return Direction.diagonal_from_offset(b_x - a_x, b_y - a_y)
end

local directions = {
  Direction.UP_LEFT,
  Direction.UP,
  Direction.UP_RIGHT,
  Direction.RIGHT,
  Direction.DOWN_RIGHT,
  Direction.DOWN,
  Direction.DOWN_LEFT,
  Direction.LEFT,
}

function Direction.from_offset(x, y)
  local angle = math.atan(y, x)
  local direction_index = math.floor(angle / math.pi * 4 + 4.5)
  return directions[direction_index % 8 + 1]
end

function Direction.diagonal_from_offset(x, y)
  if math.abs(x) > math.abs(y) then
    -- x axis direction
    if x < 0 then
      return Direction.UP_LEFT
    else
      return Direction.DOWN_RIGHT
    end
  else
    -- y axis direction
    if y < 0 then
      return Direction.UP_RIGHT
    else
      return Direction.DOWN_LEFT
    end
  end
end

local chebyshev_vectors = {
  [Direction.UP] = { x = -1, y = -1 },
  [Direction.LEFT] = { x = -1, y = 1 },
  [Direction.DOWN] = { x = 1, y = 1 },
  [Direction.RIGHT] = { x = 1, y = -1 },
  [Direction.UP_LEFT] = { x = -1, y = 0 },
  [Direction.UP_RIGHT] = { x = 0, y = -1 },
  [Direction.DOWN_LEFT] = { x = 0, y = 1 },
  [Direction.DOWN_RIGHT] = { x = 1, y = 0 },
}

function Direction.vector(direction)
  local vector = chebyshev_vectors[direction]

  if vector then
    return { x = vector.x, y = vector.y }
  end
end

local deg45radians = math.sin(math.pi / 4)
local unit_vectors = {
  [Direction.UP] = { x = -deg45radians, y = -deg45radians },
  [Direction.LEFT] = { x = -deg45radians, y = deg45radians },
  [Direction.DOWN] = { x = deg45radians, y = deg45radians },
  [Direction.RIGHT] = { x = deg45radians, y = -deg45radians },
  [Direction.UP_LEFT] = { x = -1, y = 0 },
  [Direction.UP_RIGHT] = { x = 0, y = -1 },
  [Direction.DOWN_LEFT] = { x = 0, y = 1 },
  [Direction.DOWN_RIGHT] = { x = 1, y = 0 },
}

function Direction.unit_vector(direction)
  local vector = unit_vectors[direction]

  if vector then
    return { x = vector.x, y = vector.y }
  end
end

-- todo: replace get_point_ahead or add to main library

local deg_45 = math.sin(math.pi / 4.0)

function Direction.get_point_ahead(point, direction, distance)
  local new_point = { x = point.x, y = point.y, z = point.z }

  if direction == Direction.UP_LEFT then
    new_point.x = point.x - distance
    new_point.y = point.y
  elseif direction == Direction.DOWN_RIGHT then
    new_point.x = point.x + distance
    new_point.y = point.y
  elseif direction == Direction.UP_RIGHT then
    new_point.x = point.x
    new_point.y = point.y - distance
  elseif direction == Direction.DOWN_LEFT then
    new_point.x = point.x
    new_point.y = point.y + distance
  elseif direction == Direction.RIGHT then
    new_point.x = point.x + deg_45 * distance
    new_point.y = point.y - deg_45 * distance
  elseif direction == Direction.LEFT then
    new_point.x = point.x - deg_45 * distance
    new_point.y = point.y + deg_45 * distance
  elseif direction == Direction.UP then
    new_point.x = point.x - deg_45 * distance
    new_point.y = point.y - deg_45 * distance
  elseif direction == Direction.DOWN then
    new_point.x = point.x + deg_45 * distance
    new_point.y = point.y + deg_45 * distance
  end

  return new_point
end

return Direction
