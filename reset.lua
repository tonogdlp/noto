local function reset()
	-- package.loaded["noto.init"] = nil
	package.loaded["noto.viewport"] = nil
	vim.api.nvim_clear_autocmds({
		group = vim.api.nvim_clear_autocmds({
			group = "NotoGroup",
		}),
	})
	-- require("noto.init")
	-- require("noto.viewport")
end

vim.api.nvim_create_user_command("R", reset, {})
