local Blocks = require("scripts/minecraft/data/blocks")

local OUTPUT_PATH = "/server/assets/generated/occlusion_bot.animation"

local frame_width = 29
local frame_height = 31
local originx = math.floor(frame_width / 2) + 1
local originy = 24
local layer_diff = 7.5 -- (7 + .5) since we shift the bots a pixel down for layering

local function get_state(block_id, z_offset)
  return block_id .. "_" .. z_offset
end

local CustomOriginOffset = {
  [Blocks.LADDER_E] = -7,
  [Blocks.LADDER_N] = -7,
}

local function get_originy_offset(block_id)
  return CustomOriginOffset[block_id] or 0
end

local function generate_frame(id, z_offset, col, row)
  local offset_originy = originy + get_originy_offset(id)

  local animation_frame = "animation state=\"" .. get_state(id, z_offset) .."\"\nframe duration=\"1\" "
  animation_frame = animation_frame .. "x=\"" .. (col * frame_width) .. "\" y=\"" .. (row * frame_height) .. "\" "
  animation_frame = animation_frame .. "w=\"" .. frame_width .. "\" h=\"" .. frame_height .. "\" "
  animation_frame = animation_frame .. "originx=\"" .. originx .. "\" originy=\"" .. (offset_originy + layer_diff * z_offset) .. "\"\n\n"

  return animation_frame
end

local function generate()
  local cols = 8
  local rows = 13

  local animation = "animation state=\"IDLE_U\"\nempty\n\nanimation state=\"IDLE_D\"\nempty\n\n"

  local id = 0
  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      animation = animation .. generate_frame(id, 0, col, row)
      animation = animation .. generate_frame(id, 2, col, row)
      id = id + 1
    end
  end

  Net.update_asset(OUTPUT_PATH, animation)
end

generate()

return {
  path = OUTPUT_PATH,
  get_state = get_state,
  get_originy_offset = get_originy_offset,
}
