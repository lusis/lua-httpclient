local inspect = require('inspect')
local function deep_copy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
        target[k] = cloneTable(v)
    else
        target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

local function print_table(t)
  return inspect(t)
end

utils = {
  print_table = print_table,
  deep_copy = deep_copy
}
return utils
