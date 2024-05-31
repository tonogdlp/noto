local M = {}
--- Viewport is the window that shows you a Noto DB.
---
---

---@class Event
---@field buf number
---@field event string

M.buf_id = nil
M.win_id = nil
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

---@type LineRange
M.db_location = {
	x_i = 10,
	x_f = 12,
}

M.in_viewport = false

-- { 10, 12 }

---@alias CursorPosition [integer, integer]
---

---@param cursor_pos CursorPosition
function M.is_inside_db_location(cursor_pos)
	if cursor_pos[1] >= M.db_location.x_i and cursor_pos[1] <= M.db_location.x_f then
		return true
	else
		return false
	end
end

function M.t()
	print(1)
end

function M.replace_dbmarks_in_file(filepath)
	--
end

-- DONE: Detect when entering Viewport
function M.cursor_moved_in_file_with_db()
	-- Autocmd --> when location changed, calculate if inside DB

	vim.api.nvim_create_autocmd("CursorMoved", {
		pattern = "*.testdb",
		callback = function()
			local cur = vim.api.nvim_win_get_cursor(0)
			local is_inside_db = M.is_inside_db_location(cur)
			if is_inside_db then
				if not M.in_viewport then
					M.in_viewport = true
					M.db_viewport_entered(cur)
				end
			else
				if M.in_viewport then
					M.in_viewport = false
					M.db_viewport_exited()
				end
			end
		end,
	})
end

---@param cursor_pos CursorPosition
function M.create_window_config(cursor_pos)
	-- local ui = vim.api.nvim_list_uis()[1]
	print("x: " .. cursor_pos[1] .. ", y: " .. cursor_pos[2])

	---@type WindowConfig
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

---
---@param cursor_pos CursorPosition
function M.db_viewport_entered(cursor_pos)
	print("viewport entered")

	local buf_id = vim.api.nvim_create_buf(false, true)
	-- vim.api.nvim_buf_delete(buf_id)
	-- vim.api.nvim_buf_set_name(buf_id, "../../examples/db_example1.notodb")

	vim.fn.bufload(buf_id)
	local config = M.create_window_config(cursor_pos)
	local win_id = vim.api.nvim_open_win(buf_id, true, config)

	print("BUF_id --> " .. buf_id)
	M.buf_id = buf_id
	M.win_id = win_id
end

--

-- TODO: Detect when exiting Viewport
function M.db_viewport_exited()
	--
	print("viewport exited")
	M.buf_id = nil
	M.win_id = nil
end

M.cursor_moved_in_file_with_db()

return M
