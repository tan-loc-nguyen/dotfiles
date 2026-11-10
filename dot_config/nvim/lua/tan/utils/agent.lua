-- Hand code context to coding agents (decision log §3.4).
--   reference()  "@src/api.ts#L42", "@src/api.ts#L12-20", or "@src/routes/" (from oil)
--   yank()       copy that reference to the system clipboard
--   send()       pick a herdr agent pane and type the reference into it (never presses Enter)
local M = {}

---@param opts? { absolute?: boolean }
---@return string|nil
function M.reference(opts)
	opts = opts or {}
	local modifier = opts.absolute and ":p" or ":."
	local path, suffix

	if vim.bo.filetype == "oil" then
		local oil = require("oil")
		local dir = oil.get_current_dir()
		local entry = oil.get_cursor_entry()
		if entry and entry.name ~= ".." then
			path = dir .. entry.name .. (entry.type == "directory" and "/" or "")
		else
			path = dir
		end
		path = vim.fn.fnamemodify(path, modifier)
		suffix = ""
	else
		local file = vim.api.nvim_buf_get_name(0)
		if file == "" then
			vim.notify("Buffer has no file", vim.log.levels.WARN)
			return nil
		end
		path = vim.fn.fnamemodify(file, modifier)
		local mode = vim.fn.mode()
		if mode == "v" or mode == "V" or mode == "\22" then
			local first, last = vim.fn.line("v"), vim.fn.line(".")
			if first > last then
				first, last = last, first
			end
			vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
			suffix = first == last and ("#L%d"):format(first) or ("#L%d-%d"):format(first, last)
		else
			suffix = ("#L%d"):format(vim.fn.line("."))
		end
	end
	return "@" .. path .. suffix
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
	local ref = M.reference()
	if not ref then
		return
	end
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
		-- Trailing space, no Enter: you finish the prompt yourself.
		if M.run({ "herdr", "pane", "send-text", choice.pane_id, ref .. " " }) then
			M.run({ "herdr", "agent", "focus", choice.pane_id })
		end
	end)
end

return M
