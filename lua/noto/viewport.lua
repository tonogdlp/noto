local Viewport = {}

--#region Definitions
---@alias Buf_id integer
---@alias Db_id string
---@alias Win_id integer
---@alias Vp_id string

---@alias CursorPosition [integer, integer]

---@class LineRange
---@field x_i integer
---@field x_f integer

---@class Size
---@field width integer
---@field height integer

---@class NotoViewport
---@field range LineRange
---@field width integer
---@field interior_cursor_pos CursorPosition?
---@field interior_length integer?

Viewport.vp_autogroup = vim.api.nvim_create_augroup("Noto.Viewport.Autogroup", {})

---@class Event
---@field buf number
---@field event string

Viewport.buf_id = nil
Viewport.win_id = nil

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

---@type table<Vp_id, NotoViewport>
Viewport.viewports = {}

---@type table<Vp_id, LineRange>
Viewport.vp_visible_ranges = {}

---@type table<Vp_id, integer>
Viewport.vp_windows = {}
-- 1. When first time open --> Replace dbs for current version of ViewPort
-- 		1.a Get all notodb's ranges
-- 		1.b Replace with placeholders with test preview
-- 		1.c Open Viewports (Float windows) fow each Db
-- 2. Each time cursor moves, check if it went inside notodb / viewport. if inisde:
-- 		2.a Move cursor back in the direction it came from.
-- 		2.b Enter Viewport window
-- 3. Each time a new line is added, window size changed, etc, move opened Viewports accordingly.
-- 		- Define if check should be made in one or more of:
-- 			- New leter added
-- 			- InsertLeave
-- 			- File Saved
-- 			- Window changed
-- 			- CursorHold
-- 4. When exiting a viewport:
-- 		- If exited with <ESC> -> return in the direction it entered the viewport (from above or below)
-- 		- If exited with <UP>,<DOWN>, etc. exit in the direction of movement.
-- 		- Get back to Normal mode.
-- 		- Update text to look the same as the viewport that was exited.

--#endregion

---@return Vp_id[]
function Viewport:find_viewports_code_blocks()
	-- Bail early if not in a markdown file
	if vim.bo.filetype ~= "markdown" then
		return {}
	end

	---@type NotoViewport[]

	local query_string =
	'((fenced_code_block (info_string (language)) @info_string) @block (#match? @info_string "notovp "))'
	local parser = require("nvim-treesitter.parsers").get_parser()
	local query = vim.treesitter.query.parse(parser:lang(), query_string)
	local tree = parser:parse()[1]

	-- Get data and populate each vp
	local window_width = vim.api.nvim_win_get_width(0)
	local this_x_i = 0
	local this_x_f = 0
	local found_vps_ids = {}
	for _, n in query:iter_captures(tree:root(), 0) do
		if n:type() == "fenced_code_block" then
			this_x_i, _, this_x_f, _ = n:range()
		else
			local node_text = vim.treesitter.get_node_text(n, 0, {})
			local this_vp_id = node_text:match("notovp ([^\n]+)")
			if this_vp_id ~= nil then
				Viewport.viewports[this_vp_id] = {
					width = window_width,
					range = {
						x_i = this_x_i + 1,
						x_f = this_x_f,
					},
					lenght = this_x_f - this_x_i + 1,
				}
				table.insert(found_vps_ids, this_vp_id)
			end
		end
	end
	return found_vps_ids
end

---@param vp_id Vp_id
---@returns LineRange?
local function vp_is_visible(vp_id)
	local vp = Viewport.viewports[vp_id]
	local start = vim.fn.line("w0")
	local end_ = vim.fn.line("w$")
	-- print("------->>>>>>")
	-- print("ID --> ", vp_id)
	-- print("Start = ", start, "end = ", end_)
	local x_i_visible = false
	local x_f_visible = false
	local x_i_val = vp.range.x_i
	local x_f_val = vp.range.x_f
	-- print("range x_i = ", x_i_val, "range x_f = ", x_f_val)

	if vp.range.x_i >= start and vp.range.x_i <= end_ then
		x_i_val = vp.range.x_i - start
		x_i_visible = true
	end
	if vp.range.x_f >= start and vp.range.x_f <= end_ then
		x_f_val = vp.range.x_f - start
		x_f_visible = true
	end

	-- if none visible, return nil
	if not x_i_visible and not x_f_visible then
		-- print(1)
		return nil
	elseif x_i_val - x_f_val == 0 then
		-- print(1.5)
		return nil

		-- if both visible, return both
	elseif x_i_visible and x_f_visible then
		-- print(2)
		Viewport.vp_visible_ranges[vp_id] = { x_i = x_i_val, x_f = x_f_val }

		-- if only 1 visible, return visible + first/last line
	elseif not x_i_visible then
		-- print(3)
		Viewport.vp_visible_ranges[vp_id] = { x_i = 0, x_f = x_f_val }
	else
		-- print(4)
		Viewport.vp_visible_ranges[vp_id] = { x_i = x_i_val, x_f = end_ - start }
	end

	-- print("<<<<<<<-------")
	return Viewport.vp_visible_ranges[vp_id]
end

---@param vp_id Vp_id
---@param direction "FromAbove" | "FromBelow" ?
function Viewport:open_viewport(vp_id, direction)
	-- Get VP data
	---@type LineRange?
	local range = vp_is_visible(vp_id)
	if range == nil then
		-- print("range == nil")
		return
	else
		-- print(vp_id, " range: ")
		-- P(range)
	end

	-- Set cursor outside of VP so that we can exit and not 'enter again'
	-- --TODO: Handle case when VP is first or last row in buffer.
	--

	-- Default to --> from above
	local fromAbove = true
	if direction == "FromBelow" then
		fromAbove = false
	end

	-- if fromAbove then
	-- 	vim.api.nvim_win_set_cursor(0, { range.x_i - 1, 1 })
	-- else
	-- 	vim.api.nvim_win_set_cursor(0, { range.x_f + 1, 1 })
	-- end
	--
	-- Load new buffer
	local opts = {
		relative = "win",
		-- relative = "editor",
		anchor = "NW",
		row = range.x_i,
		col = 5, --TODO: Specify `col` in plugin options
		height = math.max(range.x_f - range.x_i, 1),
		width = Viewport.viewports[vp_id].width - 30,
		border = "rounded",
		title = vp_id,
		style = "minimal",
	}

	local path = "/Users/tono/Developer/plugins/noto/lua/tests/testdb/" .. vp_id .. ".txt"

	local buf = vim.fn.call(vim.fn.bufadd, { path })
	local win = vim.api.nvim_open_win(buf, false, opts)
	Viewport.vp_windows[vp_id] = win
end

function Viewport:update_viewport_position(vp_id)
	---@type LineRange?
	local range = vp_is_visible(vp_id)

	if range == nil then
		local vp_window = Viewport.vp_windows[vp_id]
		if vp_window then
			vim.api.nvim_win_close(tonumber(vp_window), true)
			Viewport.vp_windows[vp_id] = nil
		end
		return
	end

	-- P(range)
	local vp_win = Viewport.vp_windows[vp_id]

	-- VP is not visible.
	if range == nil then
		local visible = Viewport.vp_visible_ranges[vp_id]
		-- If it was visible, close it.
		if visible then
			vim.api.nvim_win_close(vp_win, true)
		end
	end
	local vp = Viewport.viewports[vp_id]

	local cur_win = vim.api.nvim_get_current_win()
	-- If it already has a window, update it.
	if vp_win then
		local new_opts = {
			relative = "win",
			win = cur_win,
			row = range.x_i,
			height = math.max(range.x_f - range.x_i, 1),
			width = Viewport.viewports[vp_id].width - 30,
			col = 5,
		}

		local cur_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_config(vp_win, new_opts)
	else
		Viewport:open_viewport(vp_id)
	end
end

function Viewport:replace_dbmarks_in_file()
	---@param v LineRange
	for k, v in pairs(Viewport.db_locations) do
		local tmp_filepath = "./lua/tests/testdb/" .. k .. ".txt"
		local tmp_db_text = vim.fn.readfile(tmp_filepath, "")
		vim.api.nvim_buf_set_lines(0, v.x_i, v.x_f - 1, true, tmp_db_text)
	end
end

function Test()
	local found_vps_ids = Viewport:find_viewports_code_blocks()
	-- P(found_vps_ids)
	if found_vps_ids then
		local win_id = vim.api.nvim_get_current_win()
		Viewport.win_with_vps = win_id
		Viewport:create_autocmd_win_scrolled(win_id)
		Viewport:create_autocmd_cursor_moved(win_id)
		Viewport:create_autocmd_text_changed(win_id)
	else
		return
	end

	---@param vp_id NotoViewport
	for _, vp_id in pairs(found_vps_ids) do
		-- print("-----")
		local a = Viewport.viewports[vp_id]
		-- P(a)
		-- print("0----")

		Viewport:open_viewport(vp_id)
	end
end

vim.api.nvim_create_user_command("Test", Test, {})

---@param cursor_pos CursorPosition
---@return boolean, Db_id?
function Viewport:line_is_viewport(cursor_pos)
	---@param vp_id Vp_id
	---@param range LineRange
	for vp_id, vp in pairs(Viewport.viewports) do
		-- print("range: --")
		-- P(vp)
		-- print(" --:)
		if cursor_pos[1] >= vp.range.x_i and cursor_pos[1] <= vp.range.x_f then
			return true, vp_id
		end
	end
	return false, nil
end

---@param win_id integer
function Viewport:create_autocmd_cursor_moved(win_id)
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = Viewport.vp_autogroup,
		pattern = "*.md",
		callback = function()
			local cur_pos = vim.api.nvim_win_get_cursor(win_id)
			-- P(cur_pos)
			local in_vp, vp_id = Viewport:line_is_viewport(cur_pos)
			-- print("aa")
			-- P(in_vp)
			-- print("In VP:  ", tostring(in_vp), "vp_id = ", vp_id)
			if in_vp then
				--- enter VP
				local in_win_id = Viewport.vp_windows[vp_id]
				-- print("In win: ", in_win_id)
				vim.fn.win_gotoid(in_win_id)
				vim.api.nvim_win_set_cursor(in_win_id, { 1, 1 })
			end
		end,
	})
end

---@param win_id integer
function Viewport:create_autocmd_text_changed(win_id)
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		-- group = Viewport.vp_autogroup,
		pattern = "*.md",
		-- pattern = tostring(win_id),
		callback = function()
			local found_vp_ids = Viewport:find_viewports_code_blocks()
			for _, this_vp_id in pairs(found_vp_ids) do
				Viewport:update_viewport_position(this_vp_id)
			end
		end,
	})
end

---@param win_id integer
function Viewport:create_autocmd_win_scrolled(win_id)
	-- print("Win ID = ", win_id)
	vim.api.nvim_create_autocmd({ "WinScrolled" }, {
		group = Viewport.vp_autogroup,
		pattern = tostring(win_id),
		callback = function()
			-- print("Updating")
			local found_vp_ids = Viewport:find_viewports_code_blocks()
			for _, this_vp_id in pairs(found_vp_ids) do
				Viewport:update_viewport_position(this_vp_id)
			end
		end,
	})
end

---@param buf_position LineRange
function Viewport:create_window_config(buf_position)
	local opts = {
		relative = "win",
		anchor = "NW",
		row = buf_position.x_i,
		col = 3, --TODO: Specify `col` in plugin options
		height = buf_position.x_f - buf_position.x_i,
		width = 40,
		border = "rounded",
		title = "test",
		style = "minimal",
	}
	return opts
end

return Viewport
