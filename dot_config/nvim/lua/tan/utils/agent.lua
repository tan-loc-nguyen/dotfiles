-- Hand code context to coding agents (decision log §3.4).
--   reference()  "@src/api.ts#L42", "@src/api.ts#L12-20", or "@src/routes/" (from oil)
--   yank()       copy that reference to the system clipboard
--   send()       pick a herdr agent pane and type the reference into it (never presses Enter)
local M = {}

-- What the cursor points at: an absolute path (folders end in "/") plus a "#L.." suffix.
-- Leaves visual mode. Returns nil (after a warning) when there's nothing to point at.
---@return string|nil path, string|nil suffix
local function locate()
	local mode = vim.fn.mode()
	local visual = mode == "v" or mode == "V" or mode == "\22"
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	if visual then
		vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	end

	if vim.bo.filetype == "oil" then
		local oil = require("oil")
		local dir = oil.get_current_dir() -- nil for trash, ssh and other non-local views
		if not dir then
			vim.notify("Not a local folder — nothing to reference", vim.log.levels.WARN)
			return nil
		end
		local entry = oil.get_cursor_entry()
		if entry and entry.name ~= ".." then
			return dir .. entry.name .. (entry.type == "directory" and "/" or ""), ""
		end
		return dir, ""
	end

	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Buffer has no file", vim.log.levels.WARN)
		return nil
	end
	if not visual then
		return file, ("#L%d"):format(last)
	end
	if first > last then
		first, last = last, first
	end
	return file, first == last and ("#L%d"):format(first) or ("#L%d-%d"):format(first, last)
end

-- "@<path><suffix>", the path relative to `base` when it's inside it, else absolute.
local function format_ref(path, suffix, base)
	if base then
		base = vim.fs.normalize(base):gsub("/$", "") .. "/"
		if path:sub(1, #base) == base then
			path = path:sub(#base + 1)
			path = path == "" and "./" or path
		end
	end
	return "@" .. path .. suffix
end

---@param opts? { absolute?: boolean }
---@return string|nil
function M.reference(opts)
	opts = opts or {}
	local path, suffix = locate()
	if not path then
		return nil
	end
	return format_ref(path, suffix, not opts.absolute and vim.fn.getcwd() or nil)
end

function M.yank(opts)
	local ref = M.reference(opts)
	if ref then
		vim.fn.setreg("+", ref)
		vim.notify("Copied " .. ref)
	end
	return ref
end

-- Seams (replaced in tests): run a herdr command, list agents, choose one.
-- vim.system throws when the binary is missing (e.g. HERDR_ENV set but herdr not on PATH).
local function system(args)
	local ok, out = pcall(function()
		return vim.system(args, { text = true }):wait()
	end)
	return ok and out or { code = -1, stdout = "" }
end

function M.run(args)
	return system(args).code == 0
end

function M.list_agents()
	local ok, decoded = pcall(vim.json.decode, system({ "herdr", "agent", "list" }).stdout or "")
	local result = ok and type(decoded) == "table" and decoded.result -- `null` decodes to vim.NIL
	return type(result) == "table" and type(result.agents) == "table" and result.agents or {}
end

M.select = vim.ui.select

function M.send()
	local path, suffix = locate()
	if not path then
		return
	end
	local ref = format_ref(path, suffix, vim.fn.getcwd())
	if vim.env.HERDR_ENV ~= "1" then
		vim.fn.setreg("+", ref)
		vim.notify("Not inside herdr — copied " .. ref)
		return
	end

	local agents = M.list_agents()
	if #agents == 0 then
		vim.fn.setreg("+", ref)
		vim.notify("No agents running — copied " .. ref)
		return
	end

	M.select(agents, {
		prompt = "Send " .. ref .. " to",
		format_item = function(a)
			return ("%s · %s · %s"):format(a.agent, a.agent_status, a.terminal_title or a.pane_id)
		end,
	}, function(choice)
		if not choice then
			return
		end
		-- Typing into an agent that's waiting on a permission prompt could answer it.
		if choice.agent_status == "blocked" then
			vim.notify(choice.agent .. " is waiting on a prompt — nothing sent", vim.log.levels.WARN)
			return
		end
		-- Relative to the agent's own folder (it may be another worktree or repo).
		local agent_ref = choice.cwd and format_ref(path, suffix, choice.cwd) or ref
		-- Trailing space, no Enter: you finish the prompt yourself.
		if M.run({ "herdr", "pane", "send-text", choice.pane_id, agent_ref .. " " }) then
			M.run({ "herdr", "agent", "focus", choice.pane_id })
		end
	end)
end

return M
