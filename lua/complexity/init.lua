local M = {}
local utils = require("complexity.utils")
local cyclomatic_complexity = require("complexity.cyclomatic_complexity")

function M.show()
	return cyclomatic_complexity.show()
end

function M.clear()
	return cyclomatic_complexity.clear()
end

function M.setup()
	utils.register_ts_autocmd("root", function()
		M.clear()
		M.show()
	end)
end

return M
