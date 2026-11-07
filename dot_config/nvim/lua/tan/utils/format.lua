-- Which formatter runs on save, decided per project (spec §5.4):
--   * Go always uses goimports (gofmt style is universal Go convention).
--   * Everything else formats ONLY if the project declares that formatter's config.
--     No declared formatter → nothing runs, so files in repos that don't format are never
--     rewritten. <leader>cf still formats on demand.
local M = {}

local js_like = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	json = true,
	jsonc = true,
	vue = true,
}
-- prettier also covers these; oxfmt/biome are only trusted with JS/TS/JSON
local prettier_only = { css = true, scss = true, html = true, markdown = true, yaml = true, graphql = true }

local configs = {
	oxfmt = { ".oxfmtrc.json", ".oxfmtrc.jsonc" },
	biome = { "biome.json", "biome.jsonc" },
	prettier = {
		".prettierrc",
		".prettierrc.json",
		".prettierrc.yaml",
		".prettierrc.yml",
		".prettierrc.json5",
		".prettierrc.js",
		".prettierrc.cjs",
		".prettierrc.mjs",
		".prettierrc.toml",
		"prettier.config.js",
		"prettier.config.cjs",
		"prettier.config.mjs",
		"prettier.config.ts",
	},
	ruff = { "ruff.toml", ".ruff.toml" },
	shfmt = { ".editorconfig" },
	stylua = { "stylua.toml", ".stylua.toml" },
}

-- Search from the file's folder up to the git root (inclusive); never above it, so a stray
-- config in ~/Workspace can't opt a repo in. Without a git root, stop below $HOME.
local function find(bufnr, names)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		return nil
	end
	local git_root = vim.fs.root(bufnr, ".git")
	local stop = git_root and vim.fs.dirname(git_root) or vim.env.HOME
	return vim.fs.find(names, { path = vim.fs.dirname(file), upward = true, stop = stop })[1]
end

local function file_contains(path, pattern)
	local f = path and io.open(path, "r")
	if not f then
		return false
	end
	local content = f:read("*a")
	f:close()
	return content:find(pattern) ~= nil
end

local function has_prettier(bufnr)
	return find(bufnr, configs.prettier) ~= nil or file_contains(find(bufnr, { "package.json" }), '"prettier"%s*:')
end

---@return string[] conform formatter names, in try order (first available wins)
function M.formatters_for(bufnr)
	local ft = vim.bo[bufnr].filetype
	if ft == "go" then
		return { "goimports" }
	end
	if js_like[ft] then
		if find(bufnr, configs.oxfmt) then
			return { "oxfmt" }
		elseif find(bufnr, configs.biome) then
			return { "biome" }
		elseif has_prettier(bufnr) then
			return { "prettierd", "prettier" }
		end
		return {}
	end
	if prettier_only[ft] then
		return has_prettier(bufnr) and { "prettierd", "prettier" } or {}
	end
	if ft == "python" then
		local declared = find(bufnr, configs.ruff) or file_contains(find(bufnr, { "pyproject.toml" }), "%[tool%.ruff")
		return declared and { "ruff_format" } or {}
	end
	if ft == "sh" or ft == "bash" then
		return find(bufnr, configs.shfmt) and { "shfmt" } or {}
	end
	if ft == "lua" then
		return find(bufnr, configs.stylua) and { "stylua" } or {}
	end
	return {}
end

return M
