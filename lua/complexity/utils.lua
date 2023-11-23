local M = {}

function M.noop() end

function M.is_empty(v)
	return v == nil or v == ""
end

function M.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function M.enabled_when_supprted_filetype(supported_filetypes, bufnr)
	if not supported_filetypes or not bufnr then
		print("No supported filetypes or bufnr")
		return false
	end
	local filetype = vim.api.nvim_buf_get_option(bufnr, "ft")

	if M.contains(supported_filetypes, filetype) then
		return true
	end

	return false
end

function M.query_buffer(bufnr, queries)
	local filetype = vim.api.nvim_buf_get_option(bufnr, "ft")
	local lang = require("nvim-treesitter.parsers").ft_to_lang(filetype)

	local parser = vim.treesitter.get_parser(bufnr, lang)
	if not parser then
		return nil
	end

	local tree = parser:parse()
	local root = tree[1]:root()
	local parsed = vim.treesitter.query.parse(lang, queries)

	return parser, parsed, root
end

local function createIndent(tbl, length)
	for i = 1, length do
		tbl[i] = { " ", 0 }
	end
	return tbl
end

function M.is_empty_line(buf, line)
	local lines = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)

	if vim.fn.trim(lines[1]) == "" then
		return true
	end

	return false
end

function M.set_background(bufnr, ns, from, to, color)
  local hl = color or 'DiagnosticSignError'
  local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, from, -1, {
    id = from,
    priority = 1000, -- config.sign_priority,
    -- sign_text = "",
    -- sign_hl_group = nil, --  hls.hl,
    hl_group = hl, -- config.linehl and hls.linehl or nil,
    -- number_hl_group = nil, -- config.numhl and hls.numhl or nil,
     -- hl_mode = ''
  })
	-- vim.api.nvim_buf_set_extmark(bufnr, ns, from, -1, {
	-- 	hl_group = 'IlluminatedWordText',
	-- 	end_row = to,
	-- 	end_col = -1,
	-- 	priority = 1000,
	-- 	strict = false,
	-- })

	-- for i = from + 1, to - 1 do
	-- 	if not M.is_empty_line(bufnr, i) then
	-- 		local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, i, -1, {
	-- 			id = i,
	--        priority = 6, -- config.sign_priority,
	-- 			sign_text = "",
	-- 			sign_hl_group = nil, --  hls.hl,
	-- 			line_hl_group = hl, -- config.linehl and hls.linehl or nil,
	-- 			number_hl_group = nil, -- config.numhl and hls.numhl or nil,
	--        -- hl_mode = ''
	-- 		})
	-- 	end
	-- end
end

function M.set_virtual_text(ns, line, col, text, prefix, color)
	col = col or 0
	color = color or "Comment"

	text = string.format("%s", text)

	if not M.is_empty(prefix) then
		text = string.format("%s %s", prefix, text)
	end

	vim.api.nvim_buf_set_virtual_text(0, ns, line, { { text, color } }, {})
end

function M.register_ts_autocmd(name, callback)
	local augroup = "complexity" .. name
	local events = {
		"FileType",
		"BufEnter",
		-- "BufWritePost",
		"DiagnosticChanged",
	}
	vim.api.nvim_create_augroup(augroup, {})
	vim.api.nvim_create_autocmd(events, {
		group = augroup,
		callback = callback,
	})
end

return M
