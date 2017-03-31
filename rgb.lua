-- RGB API version 1.0 by CrazedProgrammer
-- You can find info and documentation on these pages:
-- http://cp.msdev.nl/computercraft/rgb-api/
-- You may use this in your ComputerCraft programs and modify it without asking.
-- However, you may not publish this API under your name without asking me.
-- If you have any suggestions, bug reports or questions then please send an email to:
-- crazedprogrammer@gmail.com
local hex = {"F0F0F0", "F2B233", "E57FD8", "99B2F2", "DEDE6C", "7FCC19", "F2B2CC", "4C4C4C", "999999", "4C99B2", "B266E5", "3366CC", "7F664C", "57A64E", "CC4C4C", "191919"}
local rgb = {}

local frgb_memory = {}

for i=1,16,1 do
  rgb[i] = {tonumber(hex[i]:sub(1, 2), 16), tonumber(hex[i]:sub(3, 4), 16), tonumber(hex[i]:sub(5, 6), 16)}
end
local rgb2 = {}
for i=1,16,1 do
  rgb2[i] = {}
  for j=1,16,1 do
    rgb2[i][j] = {(rgb[i][1] * 34 + rgb[j][1] * 20) / 54, (rgb[i][2] * 34 + rgb[j][2] * 20) / 54, (rgb[i][3] * 34 + rgb[j][3] * 20) / 54}
  end
end
 
local rightBitShift = bit.blshift
 
colors.fromRGB = function (r, g, b)
  local sav = rightBitShift( ( rightBitShift( r, 8) + g ), 8) + b
  if frgb_memory[sav] then return frgb_memory[sav] end
  local dist = 1e100
  local d = 1e100
  local color = -1
  for i=1,16,1 do
    d = math.sqrt((math.max(rgb[i][1], r) - math.min(rgb[i][1], r)) ^ 2 + (math.max(rgb[i][2], g) - math.min(rgb[i][2], g)) ^ 2 + (math.max(rgb[i][3], b) - math.min(rgb[i][3], b)) ^ 2)
    if d < dist then
      dist = d
      color = i - 1
    end
  end
  frgb_memory[sav] = 2 ^ color
  return 2 ^ color
end
 
colors.toRGB = function(color)
  return unpack(rgb[math.floor(math.log(color) / math.log(2) + 1)])
end
 
colors.fromRGB2 = function (r, g, b)
  local dist = 1e100
  local d = 1e100
  local color1 = -1
  local color2 = -1
  for i=1,16,1 do
    for j=1,16,1 do
      d = math.sqrt((math.max(rgb2[i][j][1], r) - math.min(rgb2[i][j][1], r)) ^ 2 + (math.max(rgb2[i][j][2], g) - math.min(rgb2[i][j][2], g)) ^ 2 + (math.max(rgb2[i][j][3], b) - math.min(rgb2[i][j][3], b)) ^ 2)
      if d < dist then
        dist = d
        color1 = i - 1
        color2 = j - 1
      end
    end
  end
  return 2 ^ color1, 2 ^ color2
end
 
colors.toRGB2 = function(color1, color2, str)
  local c1 = math.floor(math.log(color1) / math.log(2) + 1)
  local c2 = math.floor(math.log(color2) / math.log(2) + 1)
  return math.floor(rgb2[c1][c2][1]), math.floor(rgb2[c1][c2][2]), math.floor(rgb2[c1][c2][3])
end
 
colours.fromRGB = colors.fromRGB
colours.toRGB = colors.toRGB
colours.fromRGB2 = colors.fromRGB2
colours.toRGB2 = colors.toRGB2