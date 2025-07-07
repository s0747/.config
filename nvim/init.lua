--https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/
--
--
vim.opt.number = true
vim.opt.mouse = ''
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
-- vim.cmd.colorscheme = industry


-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  -- You can "comment out" the line below after lazy.nvim is installed
  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)

  require('lazy').setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
  {'folke/tokyonight.nvim'},
--  {'vim-airline/vim-airline'},
  {'kyazdani42/nvim-web-devicons'},
  {'nvim-lualine/lualine.nvim'},
	{
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Bardzo wysoki priorytet, aby upewnić się, że ładuje się bardzo wcześnie
    config = true,   -- Automatycznie wywołuje require("luarocks-nvim").setup()
                     -- Domyślne ustawienia są często wystarczające
  },

	 -- Przykład wtyczki: treesitter do kolorowania składni
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "rust" }, -- Dodano "rust"
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },
	 -- Przykład wtyczki: lsp-zero do serwerów językowych
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Konfiguracja dla serwerów LSP
      {'hrsh7th/cmp-nvim-lsp'},              -- Źródło autouzupełniania dla LSP
      {'hrsh7th/nvim-cmp'},                  -- Silnik autouzupełniania
      {'L3MON4D3/LuaSnip'},                  -- Obsługa snippetów
    },
    config = function()
      local lsp_zero = require("lsp-zero")
      lsp_zero.on_attach(function(client, bufnr)
        -- mapa klawiszy dla LSP
        -- Zobacz :help lsp-zero-mappings
        lsp_zero.default_keymaps({buffer = bufnr})

      --   Dodatkowe konfiguracje dla formatowania
        if client.name == "rust_analyzer" then
            -- Opcjonalnie: Ustawienie formatowania przy zapisie dla rust_analyzer
            vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
            buffer = bufnr,
            callback = function()
            vim.lsp.buf.format({ async = false })
            end,
            })
        end
      end)

      -- Zainstaluj serwery LSP dla Javy, Lua, Pythona I RUSTA!
--       require("lspconfig").jdtls.setup({}) -- Przykładowy serwer Java
      require("lspconfig").lua_ls.setup({})
--      require("lspconfig").pyright.setup({})
      -- Konfiguracja dla rust_analyzer
      require("lspconfig").rust_analyzer.setup({
        -- Dodatkowe opcje dla rust_analyzer, np. użycie clippy on save
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy", -- Użyj clippy do sprawdzania
              extraArgs = { "--workspace", "--all-targets" }, -- Przekaż dodatkowe argumenty
            },
            inlayHints = {
                enable = true, -- Włącz podpowiedzi typów
            },
            -- Inne ustawienia rust-analyzer:
            -- https://rust-analyzer.github.io/manual.html#configuration
          },
        },
      })
    end,
  },
	{
  "williamboman/mason.nvim",
  cmd = "Mason",
  config = function()
    require("mason").setup()
  end
},
{
  "williamboman/mason-lspconfig.nvim", -- Ułatwia integrację Masona z nvim-lspconfig
  dependencies = {"williamboman/mason.nvim", "neovim/nvim-lspconfig"},
  config = function()
    require("mason-lspconfig").setup({
      -- Tutaj możesz podać domyślne instalacje serwerów, np.
      --ensure_installed = {"lua_ls", "rust_analyzer", "pyright"},
    })
  end,
},
})


-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

---
-- Colorscheme
---
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')
--vim.cmd.colorscheme=('one')
vim.cmd.background='dark'


---
-- lualine.nvim (statusline)
---
vim.opt.showmode = false
require('lualine').setup({
  options = {
    icons_enabled = false,
    theme = 'tokyonight',
    component_separators = '|',
    section_separators = '',
  },
})
