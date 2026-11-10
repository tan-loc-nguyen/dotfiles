-- Tiny assertion helpers for headless checks: collect failures, then exit 0/1.
local M = { failures = {}, passed = 0, name = "check" }

function M.start(name)
	M.name = name
end

function M.ok(cond, msg)
	if cond then
		M.passed = M.passed + 1
	else
		table.insert(M.failures, msg)
	end
end

function M.eq(actual, expected, msg)
	M.ok(actual == expected, ("%s: expected %s, got %s"):format(msg, vim.inspect(expected), vim.inspect(actual)))
end

-- Print a summary and exit nvim with 0 (all passed) or 1 (any failure).
function M.finish()
	local out = {}
	for _, f in ipairs(M.failures) do
		table.insert(out, "FAIL " .. f)
	end
	table.insert(out, ("%s: %d passed, %d failed"):format(M.name, M.passed, #M.failures))
	io.stdout:write(table.concat(out, "\n") .. "\n")
	vim.cmd(#M.failures == 0 and "qa!" or "cq!")
end

-- Fail early (and still exit) if something throws.
function M.run(name, fn)
	M.start(name)
	local ok, err = xpcall(fn, debug.traceback)
	if not ok then
		table.insert(M.failures, "error: " .. tostring(err))
	end
	M.finish()
end

return M
