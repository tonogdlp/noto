---@class NotoConfig
local M = {}

---@type NotoOptions
M.options = {}

---@class NotoOptions
local defaults = {
  tmp = {},
}

---@param opts NotoOptions?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end
