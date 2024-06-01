local utils = require("noto.utils")
local config = require("noto.config")
local viewport = require("noto.viewport")

------------------------------------
---            SETUP
------------------------------------
local Noto = {}

-- -@class Noto.Settings
-- -@field db_line_prefx string

-- -@type Noto.Settings
local _defaults = {
	db_line_prefix = "[//$]",
}

function Noto.setup(opts)
	if not opts then
		opts = {}
	end
	-- -@type Noto.settings
	Noto._settings = utils.merge_table_impl(_defaults, opts)
end

Noto.setup()

return Noto
