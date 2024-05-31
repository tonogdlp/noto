for k, _ in pairs(package.loaded) do
	local tmp_k = string.find(k, "noto")
	if tmp_k then
		print(k)
	end
end
