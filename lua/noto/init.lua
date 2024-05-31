require("noto.viewport")

------------------------------------
---          DEFINITIONS
------------------------------------

---@class Noto
---@field namespace_id number
---@field group_id number
local Noto = {}

Noto.__index = Noto

------------------------------------
---            SETUP
------------------------------------
---@return Noto
function Noto:new()
	self = setmetatable({}, Noto)
	self.namespace_id = vim.api.nvim_create_namespace("noto")
	self.group_id = vim.api.nvim_create_augroup("NotoGroup", {})
	return self
end

Noto.defaults = {
	last = {},
	db_line_prefix = "[//$]",
}

function Noto.setup(opts)
	if opts == nil then
		opts = Noto.defaults
	end
	Noto:new()

	return Noto
end

Noto.setup()

return Noto
