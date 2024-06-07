--#region
-- for k, _ in pairs(package.loaded) do
-- 	local tmp_k = string.find(k, "noto")
-- 	if tmp_k then
-- 		print(k)
-- 	end
-- end
--

-- local text = '<notodb db="db1" viewport="vp1">'
--
-- print(text:match('db="([^"]+)'))

--
-- --------
-- local text = "```notovp vp1\n```"

-- local tmp_vp_name = text:match("notovp ([^ ]+)")
-- local pos_space = text:find(",", 1, true)
-- local tmp_vp_width = text:match("notodb " .. tmp_vp_name .. " ([^,]+)")
-- local tmp_vp_width = text:match("notodb " .. tmp_vp_name .. " " .. tmp_vp_width .. " ([^,]+)")
--
-- print("----")
-- print(tmp_vp_name)
-- print(pos_space)
-- print(tmp_vp_width)
-- print("-1-1-1")
-- print(vim.api.nvim_win_get_width(0))

--

-- --------

-- P(vim.fn.readfile("../tests/testdb/db1.txt", "", 5))
-- P(vim.fn.readfile("./lua/tests/testdb/db1.txt", "", 2))
--
--
--

-- ---@param buf_position LineRange
-- local opts = {
-- 	relative = "win",
-- 	anchor = "NW",
-- 	row = 10,
-- 	col = 3, --TODO: Specify `col` in plugin options
-- 	height = 5,
-- 	width = 40,
-- 	border = "rounded",
-- 	title = "test",
-- 	style = "minimal",
-- }

-- local buf_id = vim.api.nvim_create_buf(true, false)
-- vim.api.nvim_open_win(buf_id, true, opts)
-- vim.api.term
-- vim.cmd(":!flujolib -q 1 -f /Users/tono/test.xlsx")
--
-- P(vim.api.nvim_get_current_buf())
--
--
-- --------
--
-- function Test()
--   local query_string = '((fenced_code_block) @language (#match? "notovp"))'
--   local parser = require("nvim-treesitter.parsers").get_parser()
--   local query = vim.treesitter.query.parse(parser:lang(), query_string)
--   local tree = parser:parse()[1]
--   local a = 1 + 2
--   for _, n in query:iter_captures(tree:root(), 0) do
--     local node_text = vim.treesitter.get_node_text(n, 0, {})
--     P(node_text)
--   end
-- end
--
-- vim.api.nvim_create_user_command("T", Test, {})
-- P(vim.api.nvim_list_uis()[1])
--

-- vim.api.nvim_buf_delete(109, {})

-- vim.api.nvim_buf_set_name(142, "/Users/tono/Developer/plugins/noto/lua/tests/testdb/db1.txt")
-- local opts = {
--   relative = "win",
--   anchor = "NW",
--   row = 10,
--   col = 3, --TODO: Specify `col` in plugin options
--   height = 5,
--   width = 40,
--   border = "rounded",
--   title = "test",
--   style = "minimal",
-- }

-- vim.api.nvim_open_win(142, true, opts)

-- P(vim.api.nvim_get_all_options_info())
--
-- local path = "/Users/tono/Developer/plugins/noto/lua/tests/testdb/vp1.txt"
-- --
-- local buf = vim.fn.call(vim.fn.bufadd, { path })
-- local win = vim.api.nvim_open_win(buf, true, opts)
--
-- -- When reconfiguring a window, absent option keys will not be changed.
-- -- `row`/`col` and `relative` must be reconfigured together.
-- --
-- --
-- --
-- opts = {
--   relative = "win",
--   win = 1000,
--   col = 40,
--   row = 30,
-- }
--
-- vim.api.nvim_win_set_config(win, opts)
--#endregion

--

-- P(vim.fn.line("w0"))
-- -- P(vim.fn.line("w$"))
--
--
--
--
--

-- vim.api.nvim_del_autocmd(274)

local group = vim.api.nvim_create_augroup("Testing", { clear = true })

local function d(opts)
  -- P(opts)
  local num = tonumber(opts.args) + 0
  -- print(num)
  vim.api.nvim_del_autocmd(num)
end
--
-- vim.api.nvim_create_user_command("D", d, { nargs = "?" })
--
-- local a = 1
--  au_id = vim.api.nvim_create_autocmd("WinScrolled", {
--   desc = "Do something",
--   -- pattern = { "*.md", "*.markdown", "example2.md" },
--   group = group,
--   pattern = "markdown",
--   callback = function()
--     print("Wind")
--   end,
-- })
--
-- print(au_id)

--
--
--

-- Create a new augroup (autocommand group)
