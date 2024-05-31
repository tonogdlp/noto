---@class NotoConfig
local M = {}

------------------------------------
---          DEFINITIONS
------------------------------------

-- ---@class Noto.Config
-- ---@field namespace_id number
-- ---@field group_id number
-- M.__index = M
--
-- function M:new()
--   self = setmetatable({}, Noto)
--   self.namespace_id = vim.api.nvim_create_namespace("noto")
--   self.group_id = vim.api.nvim_create_augroup("NotoGroup", {})
--   return self
-- end

M.defaults = {
  last = {},
  db_line_prefix = "[//$]",
}
---@type NotoOptions
M.options = {}

---@class NotoOptions
local defaults = {
  tmp = {},
}

return M
