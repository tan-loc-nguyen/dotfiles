return {
  {
		"refractalize/oil-git-status.nvim",
		dependencies = { "stevearc/oil.nvim" },
		lazy = false,
		config = function()
			require("oil-git-status").setup()

			local function set_oil_git_hl()
				vim.api.nvim_set_hl(0, "OilGitStatusWorkingTreeModified", { fg = "#ff966c" })
				vim.api.nvim_set_hl(0, "OilGitStatusWorkingTreeAdded", { fg = "#c3e88d" })
				vim.api.nvim_set_hl(0, "OilGitStatusWorkingTreeDeleted", { fg = "#ff757f" })
				vim.api.nvim_set_hl(0, "OilGitStatusWorkingTreeUntracked", { fg = "#65bcff" })
				vim.api.nvim_set_hl(0, "OilGitStatusIndexModified", { fg = "#ff966c" })
				vim.api.nvim_set_hl(0, "OilGitStatusIndexAdded", { fg = "#c3e88d" })
				vim.api.nvim_set_hl(0, "OilGitStatusIndexDeleted", { fg = "#ff757f" })
			end

			set_oil_git_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_oil_git_hl })
		end,
	},
  {
    'stevearc/oil.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
			{ "-", "<CMD>Oil<CR>", desc = "Open parent directory", silent = true },
		},
    opts = {
      -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
      default_file_explorer = true,
      -- Id is automatically added at the beginning, and name at the end
      -- See :help oil-columns
      columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},
      -- Window-local options to use for oil buffers
      win_options = {
        wrap = false,
        signcolumn = "yes:2",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
      delete_to_trash = true,
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
      -- (:help prompt_save_on_select_new_entry)
      prompt_save_on_select_new_entry = true,
      -- Oil will automatically delete hidden buffers after this delay
      -- You can set the delay to false to disable cleanup entirely
      -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
      cleanup_delay_ms = 2000,
      lsp_file_methods = {
        -- Enable or disable LSP file operations
        enabled = true,
        -- Time to wait for LSP file operations to complete before skipping
        timeout_ms = 1000,
        -- Set to true to autosave buffers that are updated with LSP willRenameFiles
        -- Set to "unmodified" to only save unmodified buffers
        autosave_changes = false,
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          local m = name:match("^%.")
          return m ~= nil
        end,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return false
        end,
        -- Sort file names with numbers in a more intuitive order for humans.
        -- Can be "fast", true, or false. "fast" will turn it off for large directories.
        natural_order = "fast",
        -- Sort file and directory names case insensitive
        case_insensitive = false,
        sort = {
        -- sort order can be "asc" or "desc"
        -- see :help oil-columns to see which columns are sortable
          { "type", "asc" },
          { "name", "asc" },
        },
        -- Customize the highlight group for the file name
        highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
          return nil
        end,
      },
    },
  },
}
