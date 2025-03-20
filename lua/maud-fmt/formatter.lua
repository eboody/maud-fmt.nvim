local M = {}

-- Store configuration
local config = {
	indent_size = 2,
}

-- Format the current buffer's Maud HTML templates
function M.format()
	local bufnr = vim.api.nvim_get_current_buf()
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Find html! block boundaries
	local start_line = nil
	local end_line = nil
	local in_html = false
	local brace_count = 0

	for i, line in ipairs(content) do
		if line:match("html!%s*{") then
			start_line = i
			in_html = true
			brace_count = 1
		elseif in_html then
			for char in line:gmatch(".") do
				if char == "{" then
					brace_count = brace_count + 1
				elseif char == "}" then
					brace_count = brace_count - 1
				end
			end

			if brace_count == 0 then
				end_line = i
				break
			end
		end
	end

	if not start_line or not end_line then
		vim.notify("No complete html! block found", vim.log.levels.WARN)
		return
	end

	-- Extract the html block
	local html_block = {}
	for i = start_line, end_line do
		table.insert(html_block, content[i])
	end

	-- Get the base indentation from the first line
	local base_indent = html_block[1]:match("^%s*")

	-- Join with consistent line endings
	local original_text = table.concat(html_block, "\n")

	-- Fix the problem with link tags on one line
	local processed_text = original_text
		-- Add newlines after opening braces
		:gsub("{([^}])", "{\n%1")
		-- Add newlines before closing braces
		:gsub("([^{])}", "%1\n}")
		-- Don't break empty braces
		:gsub("{}([^\n])", "{}\n")
		-- Split HTML tags with attributes that are on the same line
		:gsub(
			"(%s*)link%s+([^{}]+)%s*{}",
			"\n%1link %2{}"
		)

	-- Split into lines
	local lines = {}
	for line in processed_text:gmatch("([^\n]*)\n?") do
		if line ~= "" then
			table.insert(lines, line)
		end
	end

	-- Format with proper indentation
	local result = {}
	local indent_size = config.indent_size

	-- Keep the first line as-is
	table.insert(result, lines[1])

	-- Process middle lines
	local indent_level = 1
	local in_match = false
	local in_arm = false

	for i = 2, #lines - 1 do
		local line = lines[i]
		local trimmed = line:gsub("^%s*", ""):gsub("%s*$", "")

		-- Skip empty lines
		if trimmed == "" then
			goto continue
		end

		-- Handle special syntax
		if trimmed:match("^@match") then
			in_match = true
		elseif in_match and trimmed:match("=>") then
			in_arm = true
		elseif in_arm and trimmed == "," then
			in_arm = false
		end

		-- Adjust indent for closing braces
		if trimmed:match("^}") then
			indent_level = math.max(0, indent_level - 1)
			-- Check if this is the end of a match block
			if in_match and indent_level == 0 then
				in_match = false
				in_arm = false
			end
		end

		table.insert(result, base_indent .. string.rep(" ", indent_size * indent_level) .. trimmed)

		-- Update indent level for the next line
		if trimmed:match("{%s*$") and not trimmed:match("{}%s*$") then
			indent_level = indent_level + 1
		end

		::continue::
	end

	-- Make sure the last line (closing brace) is properly indented
	if #lines > 0 then
		local last_line = lines[#lines]
		local trimmed_last = last_line:gsub("^%s*", ""):gsub("%s*$", "")

		-- If it's just a closing brace, indent it to match the opening html! { line
		if trimmed_last == "}" then
			table.insert(result, base_indent .. trimmed_last)
		else
			table.insert(result, last_line) -- Keep complex last lines as-is
		end
	end

	-- Replace the original html block with the formatted version
	vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, result)
	vim.notify("Maud HTML formatted", vim.log.levels.INFO)
end

-- Initialize the formatter with configuration
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

return M
