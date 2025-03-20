-- lua/maud-fmt/init.lua

local M = {}

-- Default configuration
local default_config = {
	indent_size = 2,
	keymaps = {
		format = "<leader>mf",
	},
	-- You can add more config options here as needed
}

-- Setup function
function M.setup(user_config)
	-- Merge user config with default config
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Load the formatter
	local formatter = require("maud-fmt.formatter")

	-- Set up the formatter with the config
	formatter.setup(config)

	-- Create the command
	vim.api.nvim_create_user_command("MaudFormat", formatter.format, {})

	-- Set up the keymap if enabled
	if config.keymaps.format then
		vim.keymap.set("n", config.keymaps.format, formatter.format, { desc = "Format Maud HTML" })
	end
end

return M
