local find_map = function(lhs)
	local maps = vim.api.nvim_get_keymap("n")
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

describe("mapstack", function()
	before_each(function()
		require("stackmap")._clear()

		-- Please don't have this mapping when we start
		-- pcall(vim.keymap.del, "n", "asdfasdf")
	end)
	it("can be required", function()
		require("stackmap")
	end)

	it("can push a single mapping", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			asdfasdf = rhs,
		})

		local found = find_map("asdfasdf")
		assert.are.same(rhs, found.rhs)
	end)

	it("can push a multiple things mapping", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test1", "n", {
			["asdf_1"] = rhs .. "1",
			["asdf_2"] = rhs .. "2",
		})

		local found_1 = find_map("asdf_1")
		local found_2 = find_map("asdf_2")
		assert.are.same(rhs .. "1", found_1.rhs)
		assert.are.same(rhs .. "2", found_2.rhs)
	end)

	it("can delete mappings after pop", function()
		local rhs = "echo 'This is a test'"
		require("stackmap").push("test3", "n", {
			["asdfasdf"] = rhs,
		})

		local found = find_map("asdfasdf")
		assert.are.same(rhs, found.rhs)

		require("stackmap").pop("test3")
		local after_pop = find_map("asdfasdf")
		assert.are.same(nil, after_pop)
	end)
end)
