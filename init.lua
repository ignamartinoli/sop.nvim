-------------
-- Options --
-------------

-- Editing

vim.opt.syntax = 'on'

-- Search

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Behaviour

vim.opt.clipboard = 'unnamedplus'
vim.opt.fsync = true
vim.opt.mouse = 'a'
vim.opt.updatetime = 250

vim.cmd [[noswapfile]]

-- UI

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true

--------------
-- Mappings --
--------------

-- Delete word

vim.keymap.set('i', '<C-BS>', [[<C-W>]], { noremap = true })

-- Softens undo

vim.keymap.set('i', ',', [[,<C-g>u]])

-- Saving

vim.keymap.set('n', '<C-s>', [[:w<CR>]], { silent = true })
vim.keymap.set('n', '<C-x>', [[:q!<CR>]], { silent = true })

-- Searching

vim.keymap.set('n', 'n', [[nzzzv]])
vim.keymap.set('n', 'N', [[Nzzzv]])
vim.keymap.set('n', '<CR>', [[:nohlsearch<CR>]], { silent = true })
vim.keymap.set('n', ',p', [["0p]], { noremap = false })
vim.keymap.set('n', ',p', [["0P]], { noremap = false })

-- Centering

vim.keymap.set('n', '<C-d>', [[zz]])

-- Indenting

vim.keymap.set('v', '<Tab>', [[>gv]])
vim.keymap.set('v', '<S-Tab>', [[<gv]])


-------------
-- Plugins --
-------------

return require 'packer'.startup(function ()

	-- Plugin Manager

	use 'wbthomason/packer.nvim'

	-- LSP

	use {
		'neovim/nvim-lspconfig',
		after = 'mason-lspconfig.nvim',
		config = function ()
			local lsp = require 'lspconfig'

			local servers = {
				bashls = {},
				pyright = {},
				sumneko_lua = {
					settings = {
						Lua = {
							runtime = { version = 'LuaJIT' },
							diagnostics = {
								globals = { 'use', 'vim' }
							},
							format = { enable = false }
						}
					}
				}
			}

			local signs = {
				DiagnosticSignError = 'E',
				DiagnosticSignHint = 'H',
				DiagnosticSignInfo = 'I',
				DiagnosticSignWarn = 'W'
			}
			for type, icon in pairs(signs) do
				vim.fn.sign_define(type, { text = icon, texthl = type, linehl = type, numhl = type })
			end

			
			vim.diagnostic.config {
				float = { header = '', prefix = '' },
				severity_sort = true,
				virtual_text = false
			}


			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				pattern = '*',
				callback = function () vim.diagnostic.open_float(nil, { focus = false }) end
			})

			vim.opt.shortmess:append 'c'

			for server, config in pairs(servers) do
				config = vim.tbl_deep_extend('keep', config, {
					capabilities = require 'cmp_nvim_lsp'.default_capabilities(vim.lsp.protocol.make_client_capabilities()),
					on_attach = function ()
						vim.keymap.set('n', 'ga', vim.lsp.buf.code_action)
						vim.keymap.set('n', 'gd', function () require 'telescope.builtin'.diagnostics() end)
						vim.keymap.set('n', 'gi', function () require 'telescope.builtin'.lsp_implementations() end)
						vim.keymap.set('n', 'gr', function () require 'telescope.builtin'.lsp_references() end)
						vim.keymap.set('n', 'gs', function () require 'telescope.builtin'.spell_suggest() end)
						vim.keymap.set('n', 'K', vim.lsp.buf.hover)
					end
				})

				lsp[server].setup(config)
			end
		end,
		requires = {
			'hrsh7th/cmp-nvim-lsp',
			{ 'williamboman/mason.nvim', config = function () require 'mason'.setup() end },
			{ 'williamboman/mason-lspconfig.nvim', after = 'mason.nvim', config = function () require 'mason-lspconfig'.setup() end },
			{
				'WhoIsSethDaniel/mason-tool-installer.nvim',
				config = function () require 'mason-tool-installer'.setup {
					ensure_installed = {
						{ 'bash-language-server', auto_update = true },
						{ 'lua-language-server', auto_update = true },
						{ 'pyright', auto_update = true },
						{ 'shellcheck', auto_update = true }
					}
				} end
			}
		}
	}

	-- Completion

	use {
		'hrsh7th/nvim-cmp',
		config = function ()
			local cmp = require 'cmp'
			local typ = require 'cmp.types'
			local snp = require 'luasnip'

			local has_words_before = function ()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup {
				completion = { completeopt = 'menu,menuone,noselect' },
				mapping = cmp.mapping.preset.insert {
					['<Down>'] = cmp.mapping.close(),
					['<Up>'] = cmp.mapping.close(),
					['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace },
					['<Tab>'] = cmp.mapping(function (fallback)
						if cmp.visible() then cmp.select_next_item()
						elseif snp.expand_or_jumpable() then snp.expand_or_jump()
						elseif has_words_before() then cmp.complete()
						else fallback() end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function (fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif snp.jumpable(-1) then
							snp.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' })
				},
				preselect = typ.cmp.PreselectMode.None,
				snippet = {
					expand = function (args)
						snp.lsp_expand(args.body)
					end
				},
				sources = {
					{ name = 'nvim_lsp' },
					{
						name = 'luasnip',
						option = { use_show_condition = false }
					},
					{ name = 'neorg' },
					{ name = 'path' },
					{ name = 'buffer' }
				},
				window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() }
			}

			require 'cmp'.event:on('confirm_done', require 'nvim-autopairs.completion.cmp'.on_confirm_done())
		end,
		requires = {
			{ 'hrsh7th/cmp-path' },
			{ 'saadparwaiz1/cmp_luasnip' },
			{ 'L3MON4D3/LuaSnip' }
		}
	}

	-- Syntax

	use {
		'nvim-treesitter/nvim-treesitter',
		config = function () require 'nvim-treesitter.configs'.setup {
			highlight = { enable = true },
			indent = { enable = true },
			rainbow = { enable = true, extended_mode = true, max_file_lines = nil }
		} end,
		requires = { 'p00f/nvim-ts-rainbow', after = 'nvim-treesitter' }
	}

	-- Terminal Integration

	use {
		'akinsho/toggleterm.nvim',
		config = function () require 'toggleterm'.setup {
			direction = 'horizontal',
			insert_mappings = false,
			open_mapping = [[<C-t>]],
			float_opts = {
				border = 'curved',
				winblend = 6
			}
		} end
	}

	-- Fuzzy Finder

	use {
		'nvim-telescope/telescope.nvim',
		config = function ()
			require 'telescope.actions'

			require 'telescope'.setup {
				extensions = {
					fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' },
					['ui-select'] = { require 'telescope.themes'.get_dropdown() }
				},
				vimgrep_argument = { 'rg', '--smart-case' }
			}

			require 'telescope'.load_extension 'fzf'
			require 'telescope'.load_extension 'ui-select'
		end,
		requires = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
			'nvim-telescope/telescope-ui-select.nvim'
		},
		setup = function ()
			vim.keymap.set('n', '<C-f>', function () require 'telescope.builtin'.live_grep() end)
			vim.keymap.set('n', '<C-c>', function () require 'telescope'.load_extension('todo-comments').todo() end)
		end
	}

	-- Colorscheme

	use {
		'catppuccin/nvim',
		as = 'catppuccin',
		config = function ()
			require 'catppuccin'.setup {
				compile = { enabled = true },
				flavour = 'macchiato',
				integrations = { ts_rainbow = true }
			}

			require 'catppuccin'.load()
		end
	}

	-- Statusline

	use {
		'nvim-lualine/lualine.nvim',
		config = function ()
			require 'lualine'.setup {
				options = {
					globalstatus = true,
					component_separators = {
						left = '',
						right = ''
					},
					section_separators = {
						left = '',
						right = ''
					}
				},
				extensions = { 'man', 'toggleterm' },
				sections = {
					lualine_b = { 'diagnostics' },
					lualine_x = { 'location' },
					lualine_y = { 'progress' },
					lualine_z = { 'filename' }
				},
				inactive_sections = {}
			}

			vim.opt.showmode = false
		end
	}

	-- Indent

	use {
		'lukas-reineke/indent-blankline.nvim',
		config = function () require 'indent_blankline'.setup { char = '▏', show_current_context = true } end
	}

	-- Editing Support

	use {
		'windwp/nvim-autopairs',
		config = function ()
			require 'nvim-autopairs'.setup {
				disable_filetype = { 'markdown', 'TelescopePrompt' }
			}

			local pair = require 'nvim-autopairs'
			local rule = require 'nvim-autopairs.rule'

			pair.add_rules {
				rule(' ', ' ')
					:with_pair(function (opts)
						return vim.tbl_contains({ '()', '[]', '{}' }, opts.line:sub(opts.col - 1, opts.col))
					end),
				rule('( ', ' )')
					:with_pair(function () return false end)
					:with_move(function (opts) return opts.prev_char:match '.%)' ~= nil end)
					:use_key ')',
				rule('[ ', ' ]')
					:with_pair(function () return false end)
					:with_move(function (opts) return opts.prev_char:match '.%}' ~= nil end)
					:use_key ']',
				rule('{ ', ' }')
					:with_pair(function () return false end)
					:with_move(function (opts) return opts.prev_char:match '.%}' ~= nil end)
					:use_key '}'
			}
		end
	}
end)
