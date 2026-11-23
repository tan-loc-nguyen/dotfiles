-- Stop the live-preview server once its last browser tab is gone. The plugin never does that
-- itself: a closed tab only drops off its `connecting_clients` list, and the server (and its
-- port) stay up until `:LivePreview close` or quitting nvim. This polls that list.
--   * a refresh reconnects inside the grace period, so it never stops the server
--   * a server no tab ever connected to is left alone (a slow browser looks the same)
-- Reads the plugin's internal `server.connecting_clients`; tests/nvim/check_livepreview.lua
-- fails if an update renames it.
local M = {}

local timer

---@param opts? { interval_ms?: integer, grace_ms?: integer }
function M.setup(opts)
	opts = vim.tbl_extend("force", { interval_ms = 2000, grace_ms = 5000 }, opts or {})

	-- setup() may run again (the test uses short timings): replace the old timer
	if timer then
		timer:stop()
		timer:close()
	end
	timer = vim.uv.new_timer()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("tan_livepreview_autostop", { clear = true }),
		callback = function()
			if timer and not timer:is_closing() then
				timer:stop()
				timer:close()
			end
		end,
	})

	local current, seen, empty_since -- tied to one server instance; reset when it restarts
	local function reset(server_obj)
		current, seen, empty_since = server_obj, false, nil
	end

	timer:start(
		opts.interval_ms,
		opts.interval_ms,
		vim.schedule_wrap(function()
			local lp = package.loaded["livepreview"] -- don't load the plugin just to look
			if not (lp and lp.is_running()) then
				reset(nil)
				return
			end
			if lp.serverObj ~= current then
				reset(lp.serverObj)
			end

			if #require("livepreview.server").connecting_clients > 0 then
				seen, empty_since = true, nil
			elseif seen then
				empty_since = empty_since or vim.uv.now()
				if vim.uv.now() - empty_since >= opts.grace_ms then
					lp.close()
					reset(nil)
				end
			end
		end)
	)
end

return M
