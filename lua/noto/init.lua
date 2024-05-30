------------------------------------
---          DEFINITIONS
------------------------------------

---@class Noto
---@field namespace_id number
---@field group_id number
local Noto = {}

Noto.__index = Noto

local namespace_id = vim.api.nvim_create_namespace("noto")
local noto_group = vim.api.nvim_create_augroup("NotoGroup", {})
local autocmd = vim.api.nvim_create_autocmd

---@class WindowConfig
---@field relative string
---@field anchor string
---@field row number
---@field col number
---@field height number
---@field width number
---@field border string
---@field title string
---@field style string

---@class Event
---@field buf number
---@field event string

----
---
---
---
---
------------------------------------
---            FUNCTIONS
------------------------------------

---@class NotoOption
---@return WindowConfig
function Noto.create_window_config()
	-- local ui = vim.api.nvim_list_uis()[1]
	local pos = vim.api.nvim_win_get_cursor(0)
	print("x: " .. pos[1] .. ", y: " .. pos[2])

	return {
		relative = "cursor",
		anchor = "NW",
		row = 0,
		col = 0,
		height = 10,
		width = 30,
		border = "rounded",
		title = "test",
		style = "minimal",
	}
end

function Noto.create_window()
	local buf_id = vim.api.nvim_create_buf(false, true)
	local config = Noto.create_window_config()
	local win_id = vim.api.nvim_open_win(buf_id, true, config)

	print("BUF_id --> " .. buf_id)
	return buf_id, win_id
end

---@return Noto
function Noto:new()
	print("aaa -->")
	P(Noto)
	local self = setmetatable({}, Noto)
	self.namespace_id = vim.api.nvim_create_namespace("noto")
	self.group_id = vim.api.nvim_create_augroup("NotoGroup", {})
	return self
end

Noto.defaults = {
	last = {},
}

function Noto.setup(opts)
	if opts == nil then
		opts = Noto.defaults
	end
	print("setup init")
	Noto:new()
	-- Noto.options = vim.tbl_deep_extend("force", {}, defaults, opts)
	vim.api.nvim_create_user_command("NotoWin", Noto.create_window, {})
	Noto.db_pos = { 10, 23 }
	autocmd({
		"BufEnter",
	}, {
		group = noto_group,
		---@param event Event
		callback = function(event) end,
	})

	return Noto
end

------------------------------------
---            SETUP
------------------------------------

Noto.setup()

------------------------------------
---            USE
------------------------------------

Noto.create_window()

-- Noto.created = false

vim.api.nvim_create_user_command("Noto", function()
	vim.api.nvim_command('lua require("noto").create_window()')
end, {})
require("noto.reload")

local reload = function()
	package.loaded.Noto = nil
	require("noto").setup()
end
vim.api.nvim_create_user_command("T", reload, {})
return Noto

-- M.created = false
-- M.db_pos = { 10, 23 }
-- M.files_with_db = { "example.md" }

-- local find_db_pos = function() end

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--
-- 	callback = function()
-- 		local this_filename = "tmp.txt"
-- 		if has_value(M.files_with_db, this_filename) then
-- 			-- test
-- 		end
-- 	end,
-- })

-- return M
