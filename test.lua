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
-- local text = "```notodb db1\n```"
--
--
-- print(text:match("notodb ([^\n]+)"))
--
--
--
-- --------

-- P(vim.fn.readfile("../tests/testdb/db1.txt", "", 5))
P(vim.fn.readfile("./lua/tests/testdb/db1.txt", "", 2))
