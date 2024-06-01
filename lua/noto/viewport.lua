local Viewport = {}
--- Viewport is the window that shows you a Noto DB.
---
---

Viewport.vp_autogroup = vim.api.nvim_create_augroup("Noto.Viewport.Autogroup", {})

---@class Event
---@field buf number
---@field event string

Viewport.buf_id = nil
Viewport.win_id = nil
---@class LineRange
---@field x_i number
---@field x_f number

---@class WindowConfig
---@field relative string
---@field anchor "NW"|"SW"|"NE"|"SE"
---@field row number
---@field col number
---@field height number
---@field width number
---@field border string
---@field title string
---@field style string

Viewport.in_viewport = false

---@alias Db_Locations table<string, LineRange>
Viewport.db_locations = {}

function Viewport:update_db_locations()
	local query_string = '((fenced_code_block) @fenced_code_block (#eq? "notodb"))'
	local parser = require("nvim-treesitter.parsers").get_parser()
	local query = vim.treesitter.query.parse(parser:lang(), query_string)
	local tree = parser:parse()[1]
	for _, n in query:iter_captures(tree:root(), 0) do
		local node_text = vim.treesitter.get_node_text(n, 0, {})
		local tmp_db_name = node_text:match("notodb ([^\n]+)")
		Viewport.db_locations[tmp_db_name] = {
			x_i = n:start() + 1,
			x_f = n:end_(),
		}
	end
end

function test()
	Viewport:update_db_locations()
	Viewport:replace_dbmarks_in_file()
	P(Viewport.db_locations)
end

vim.api.nvim_create_user_command("Test", test, {})

-- { 10, 12 }

---@alias CursorPosition [integer, integer]
---

---@param cursor_pos CursorPosition
function Viewport.line_is_notodb(cursor_pos)
	for k, v in Viewport.db_locations do
	end
	if cursor_pos[1] >= Viewport.db_location.x_i and cursor_pos[1] <= Viewport.db_location.x_f then
		return true
	else
		return false
	end
end

function Viewport.replace_dbmarks_in_file(filepath)
	local tmp_db_text = {
		"id |  date       |  person  | payment",
		"1  |  2024-05-01 | Angel A. | 123.45",
		"2  |  2024-05-03 | Bandit H.| 678.91",
		"3  |  2024-05-04 | Chili H. | 234.56",
		"4  |  2024-05-10 | Daniel G.| 789.10",
		"5  |  2024-05-10 | Daniel G.| 789.10",
	}

	---@param v LineRange
	for k, v in pairs(Viewport.db_locations) do
		vim.api.nvim_buf_set_lines(0, v.x_i, v.x_f - 1, true, tmp_db_text)
	end
end

-- DONE Detect when entering Viewport
function Viewport.cursor_moved_in_file_with_db()
	-- Autocmd --> when location changed, calculate if inside DB

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = Viewport.vp_autogroup,
		pattern = "*.testdb",
		callback = function()
			local cur = vim.api.nvim_win_get_cursor(0)
			local is_inside_db = Viewport.line_is_notodb(cur)
			if is_inside_db then
				if not Viewport.in_viewport then
					Viewport.in_viewport = true
					Viewport.db_viewport_entered(cur)
				end
			else
				if Viewport.in_viewport then
					Viewport.in_viewport = false
					Viewport.db_viewport_exited()
				end
			end
		end,
	})
end

---@param cursor_pos CursorPosition
function Viewport.create_window_config(cursor_pos)
	local opts = {
		relative = "win",
		anchor = "NW",
		row = cursor_pos[1],
		col = 3,
		height = 10,
		width = 30,
		border = "rounded",
		title = "test",
		style = "minimal",
	}
	return opts
end

---@param cursor_pos CursorPosition
function Viewport.db_viewport_entered(cursor_pos)
	print("viewport entered")

	local buf_id = vim.api.nvim_create_buf(false, true)

	vim.fn.bufload(buf_id)
	local config = Viewport.create_window_config(cursor_pos)
	local win_id = vim.api.nvim_open_win(buf_id, true, config)

	print("BUF_id --> " .. buf_id)
	Viewport.buf_id = buf_id
	Viewport.win_id = win_id
end

--

-- TODO: Detect when exiting Viewport
function Viewport.db_viewport_exited()
	--
	print("viewport exited")
	Viewport.buf_id = nil
	Viewport.win_id = nil
end

Viewport.cursor_moved_in_file_with_db()

return Viewport
