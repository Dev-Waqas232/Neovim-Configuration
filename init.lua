-- Leader key
vim.g.mapleader = " "

-- Options
vim.opt.number = true -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.tabstop = 2 -- 2 space tabs
vim.opt.shiftwidth = 2 -- indent size
vim.opt.expandtab = true -- spaces instead of tabs
vim.opt.smartindent = true -- smart indenting
vim.opt.wrap = true -- line wrap
vim.opt.termguicolors = true -- true colors
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor
vim.opt.mouse = "a" -- enable mouse
vim.opt.clipboard = "unnamedplus" -- copy to system clipboard

-- Universal data paths (Works flawlessly on Ubuntu and Arch btw)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

local excluded = { neo_tree = true, TelescopePrompt = true, alpha = true }
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function(args)
		if excluded[vim.bo[args.buf].filetype] then
			return
		end
		pcall(vim.treesitter.start, args.buf)
	end,
})

-- LSP configs (must be before lazy)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			validate = true,
			hover = true,
			completion = true,
			schemas = {
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
				["https://json.schemastore.org/kubernetes.json"] = "*.k8s.yaml",
			},
		},
	},
})

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
			gofumpt = true,
		},
	},
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({

	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		priority = 1000,
		config = function()
			vim.cmd("colorscheme tokyonight-night")
			vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
			vim.cmd("highlight NormalNC guibg=NONE ctermbg=NONE")
			vim.cmd("highlight SignColumn guibg=NONE")
		end,
	},

	-- Dashboard Landing Page
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Initialize highlight groups before rendering layouts to prevent UI stutter
			vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#4FC3F7", bold = true })
			vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#7DCFFF" })

			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				"██╗     ██╗ █████╗  ██████╗  █████╗ ███████╗",
				"██║     ██║██╔══██╗██╔═══██╗██╔══██╗██╔════╝",
				"██║ █╗  ██║███████║██║    ██║███████║███████╗",
				"██║███╗ ██║██╔══██║██║▄▄  ██║██╔══██║╚════██║",
				"╚███╔███╔╝ ██║  ██║╚██████╔╝██║  ██║███████║",
				" ╚══╝╚══╝  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝",
				"",
				"Software Engineer • Professional Bug Archaeologist",
				"",
			}
			dashboard.section.header.opts.hl = "AlphaHeader"

			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
				dashboard.button("g", "  Live Grep", ":Telescope live_grep<CR>"),
				dashboard.button("p", "  Open Project", ":Telescope projects<CR>"),
				dashboard.button("l", "󰒲  Lazy Installer", ":Lazy<CR>"),
				dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
			}

			dashboard.section.footer.val = {
				"",
				"▸ Every commit tells a story. Most are horror stories.",
				"▸ Regret-driven development.",
				"▸ The consequences of past optimism.",
				"▸ Trusting myself from six months ago was a mistake.",
				"▸ Fixing one bug at a time, creating three more.",
				"▸ There is nothing more permanent than a temporary fix.",
				"▸ It's not a bug, it's undocumented behavior.",
				"",
				"> Welcome back, Waqas.",
			}
			dashboard.section.footer.opts.hl = "AlphaFooter"

			dashboard.opts.layout = {
				{ type = "padding", val = 5 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = 2 },
				dashboard.section.footer,
			}

			dashboard.section.header.opts.position = "center"
			dashboard.section.buttons.opts.position = "center"
			dashboard.section.footer.opts.position = "center"

			alpha.setup(dashboard.opts)
		end,
	},

	-- Project Manager (Tracks root directories and patterns)
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "lsp", "pattern" },
				patterns = { ".git", "Makefile", "package.json", "go.mod" },
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				ensure_installed = {
					"lua",
					"javascript",
					"typescript",
					"python",
					"json",
					"bash",
					"yaml",
					"markdown",
					"markdown_inline",
					"go",
					"css",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })

			-- Hook projects extension directly into telescope engine
			require("telescope").load_extension("projects")
		end,
	},

	-- Mason (LSP installer)
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason LSPConfig bridge
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "ts_ls", "lua_ls", "pyright", "yamlls", "gopls", "cssls" },
				automatic_enable = true,
			})
		end,
	},

	-- LSP Config
	{ "neovim/nvim-lspconfig" },

	-- Lualine
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight-night",
					globalstatus = true,
					component_separators = { left = "|", right = "|" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Neo-tree (Persistent File Explorer Sidebar)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				window = {
					width = 30,
				},
				filesystem = {
					sync_root_with_cwd = true, -- Force Neo-Tree to sync whenever project changes
					filtered_items = {
						visible = true,
					},
				},
			})
			vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle left<cr>", { desc = "Toggle file explorer sidebar" })
		end,
	},

	-- Git Signs (Line changes in gutters)
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- Visual Todo Comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup()
			vim.keymap.set("n", "<leader>ft", ":TodoTelescope<CR>", { desc = "Find TODOs" })
		end,
	},

	-- Quick Code Commenting (`gcc` to comment line, `gc` in visual block)
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Conform (formatter)
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					yaml = { "prettier" },
					yml = { "prettier" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					json = { "prettier" },
					css = { "prettier" },
					lua = { "stylua" },
					go = { "gofumpt" },
					python = { "black" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})

			-- Manual format trigger with Space + m + p
			vim.keymap.set("n", "<leader>mp", function()
				require("conform").format({ lsp_fallback = true, timeout_ms = 500 })
			end, { desc = "Format file manually" })
		end,
	},

	-- Auto complete engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),

				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	{
		"monkoose/neocodeium",
		event = "InsertEnter",
		config = function()
			local neocodeium = require("neocodeium")

			neocodeium.setup({
				manual = false,
				debounce = true,
				silent = true,
			})

			vim.keymap.set("i", "<A-f>", function()
				neocodeium.accept()
			end)

			vim.keymap.set("i", "<A-w>", function()
				neocodeium.accept_word()
			end)

			vim.keymap.set("i", "<A-l>", function()
				neocodeium.accept_line()
			end)

			vim.keymap.set("i", "<A-]>", function()
				neocodeium.cycle_or_complete()
			end)

			vim.keymap.set("i", "<A-[>", function()
				neocodeium.cycle_or_complete(-1)
			end)

			vim.keymap.set("i", "<C-]>", function()
				neocodeium.clear()
			end)
		end,
	},
})

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ts_ls",
	"gopls",
	"yamlls",
	"cssls",
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("pyright", {
	capabilities = capabilities,
})

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})

vim.lsp.config("gopls", {
	capabilities = capabilities,
})

vim.lsp.config("yamlls", {
	capabilities = capabilities,
	settings = {
		yaml = {
			validate = true,
			completion = true,
		},
	},
})

vim.lsp.config("cssls", {
	capabilities = capabilities,
})
