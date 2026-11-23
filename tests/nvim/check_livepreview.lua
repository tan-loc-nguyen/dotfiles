-- live-preview auto-stop: the server stops once the last browser tab is gone, but not on a
-- refresh (tab reconnects inside the grace period) and not when no tab ever connected.
-- Tabs are simulated with raw sockets doing the real `Upgrade: websocket` handshake.
local t = dofile(vim.env.TESTS_DIR .. "/helpers.lua")
local uv = vim.uv

local lp = require("livepreview")
local server = require("livepreview.server")
local GRACE = 500

local function free_port()
	local s = uv.new_tcp()
	s:bind("127.0.0.1", 0)
	local port = s:getsockname().port
	s:close()
	return port
end

-- Open a fake browser tab; returns its socket once the server answered 101.
local function connect(port)
	local sock = uv.new_tcp()
	local upgraded = false
	sock:connect("127.0.0.1", port, function(err)
		assert(not err, err)
		sock:read_start(function(_, chunk)
			if chunk and chunk:find("101", 1, true) then
				upgraded = true
			end
		end)
		sock:write(
			"GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
				.. ("Sec-WebSocket-Key: %s\r\nSec-WebSocket-Version: 13\r\n\r\n"):format(
					vim.base64.encode("livepreview-test")
				)
		)
	end)
	vim.wait(2000, function()
		return upgraded
	end, 10)
	t.ok(upgraded, "fake tab got the websocket upgrade")
	return sock
end

local function start_server()
	local port = free_port()
	lp.start("tab.md", port)
	return port
end

t.run("livepreview", function()
	-- guards against an upstream rename of the field the timer reads
	t.ok(type(server.connecting_clients) == "table", "plugin still exposes server.connecting_clients")

	require("tan.utils.livepreview").setup({ interval_ms = 50, grace_ms = GRACE })

	-- a tab is connected: stays up well past the grace period
	local port = start_server()
	local tab = connect(port)
	vim.wait(GRACE * 2)
	t.ok(lp.is_running(), "server stays up while a tab is connected")

	-- last tab closes: server stops after the grace period
	tab:close()
	t.ok(
		vim.wait(3000, function()
			return not lp.is_running()
		end, 20),
		"server stops after the last tab closes"
	)

	-- refresh: the tab drops and reconnects inside the grace period
	port = start_server()
	tab = connect(port)
	vim.wait(150) -- a few ticks, so the timer has seen this tab connected
	tab:close()
	-- long enough that a missing grace period would already have stopped it (a few 50 ms
	-- ticks), short enough that the real one (500 ms) has not expired
	vim.wait(GRACE * 0.6)
	tab = connect(port)
	vim.wait(GRACE * 2)
	t.ok(lp.is_running(), "server stays up when the tab reconnects within the grace period")
	tab:close()
	vim.wait(3000, function()
		return not lp.is_running()
	end, 20)

	-- no tab ever connected: nothing to compare against, so it stays up
	start_server()
	vim.wait(GRACE * 3)
	t.ok(lp.is_running(), "server stays up when no tab ever connected")
	lp.close()
end)
