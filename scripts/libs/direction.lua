local Direction = {
  UP = "Up",
  LEFT = "Left",
  DOWN = "Down",
  RIGHT = "Right",
  UP_LEFT = "Up Left",
  UP_RIGHT = "Up Right",
  DOWN_LEFT = "Down Left",
  DOWN_RIGHT = "Down Right",
}

local reverse_table = {
  ["Up"] = "Down",
  ["Left"] = "Left",
  ["Down"] = "Up",
  ["Right"] = "Left",
  ["Up Left"] = "Down Right",
  ["Up Right"] = "Down Left",
  ["Down Left"] = "Up Right",
  ["Down Right"] = "Up Left",
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
  "Up Left",
  "Up",
  "Up Right",
  "Right",
  "Down Right",
  "Down",
  "Down Left",
  "Left",
}

function Direction.from_offset(x, y)
  local angle = math.atan(y, x)
  local direction_index = math.floor(angle / math.pi * 4) + 5
  return directions[direction_index]
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

local deg_45 = math.sin(math.pi / 4.0)

function Direction.get_point_ahead(point, direction, distance)
  local new_point = { x = point.x, y = point.y, z = point.z }

  if direction == Direction.left then
     new_point.x = point.x - distance
     new_point.y = point.y
  elseif direction == Direction.right then
    new_point.x = point.x + distance
    new_point.y = point.y
  elseif direction == Direction.up then
    new_point.x = point.x
    new_point.y = point.y - distance
  elseif direction == Direction.down then
    new_point.x = point.x
    new_point.y = point.y + distance
  elseif direction == Direction.up_left then
    new_point.x = point.x - deg_45 * distance
    new_point.y = point.y - deg_45 * distance
  elseif direction == Direction.up_right then
    new_point.x = point.x + deg_45 * distance
    new_point.y = point.y - deg_45 * distance
  elseif direction == Direction.down_left then
    new_point.x = point.x - deg_45 * distance
    new_point.y = point.y + deg_45 * distance
  elseif direction == Direction.down_right then
    new_point.x = point.x + deg_45 * distance
    new_point.y = point.y + deg_45 * distance
  end

  return new_point
end

return Direction
