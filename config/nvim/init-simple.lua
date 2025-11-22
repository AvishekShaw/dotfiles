-- ============================================================================
-- ~/.config/nvim/init.lua (Simple - No Plugin Manager)
-- ============================================================================
-- This version loads plugins from ~/.local/share/nvim/lazy/ without lazy.nvim
-- Use this if lazy.nvim fails or you want a simpler setup

-- ============================================================================
-- BASIC SETTINGS
-- ============================================================================

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Code Folding
vim.o.foldmethod = "indent"
vim.o.foldlevel = 4

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- UI
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- Behavior
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ============================================================================
-- LEADER KEYS
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ============================================================================
-- MANUALLY LOAD PLUGINS FROM ~/.local/share/nvim/lazy/
-- ============================================================================

local lazy_dir = vim.fn.stdpath("data") .. "/lazy"

-- Add all plugin directories to runtimepath
local plugin_dirs = vim.fn.glob(lazy_dir .. "/*", false, true)
for _, dir in ipairs(plugin_dirs) do
  vim.opt.rtp:append(dir)
end

-- ============================================================================
-- PLUGIN CONFIGURATIONS
-- ============================================================================

-- Colorscheme (catppuccin)
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "mocha",
    transparent_background = false,
  })
  vim.cmd.colorscheme("catppuccin")
else
  vim.notify("Catppuccin not found, using default colorscheme", vim.log.levels.WARN)
end

-- nvim-tree (File Explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local tree_ok, nvim_tree = pcall(require, "nvim-tree")
if tree_ok then
  nvim_tree.setup({
    sort = { sorter = "case_sensitive" },
    view = { adaptive_size = true, side = "left" },
    renderer = {
      group_empty = true,
      icons = {
        show = { file = true, folder = true, folder_arrow = true, git = true },
      },
    },
    filters = { dotfiles = false },
    git = { enable = true, ignore = false },
  })
end

-- nvim-cmp (Completion)
local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
  local luasnip_ok, luasnip = pcall(require, "luasnip")

  if luasnip_ok then
    require("luasnip.loaders.from_vscode").lazy_load()
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        if luasnip_ok then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip_ok and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip_ok and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "obsidian" },
      { name = "buffer" },
      { name = "path" },
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
  })
end

-- Obsidian (commented out - uncomment if you use Obsidian)
-- local obsidian_ok, obsidian = pcall(require, "obsidian")
-- if obsidian_ok then
--   obsidian.setup({
--     workspaces = {
--       { name = "notes", path = "~/Documents/notes" },
--     },
--     daily_notes = {
--       folder = "daily",
--       date_format = "%Y-%m-%d",
--     },
--     completion = {
--       nvim_cmp = true,
--       min_chars = 2,
--     },
--   })
-- end

-- Telescope
local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  })
end

-- Treesitter (commented out - requires compilation/build tools)
-- local treesitter_ok, treesitter = pcall(require, "nvim-treesitter.configs")
-- if treesitter_ok then
--   treesitter.setup({
--     -- Don't auto-install parsers (requires git + build tools)
--     ensure_installed = {},
--     auto_install = false,
--     -- Only enable if parsers are pre-installed
--     highlight = { enable = false },
--     indent = { enable = false },
--   })
-- end

-- Use Neovim's built-in syntax highlighting instead
vim.cmd([[syntax enable]])

-- Gitsigns
local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
  gitsigns.setup({
    signs = {
      add          = { text = '│' },
      change       = { text = '│' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
  })
end

-- Render Markdown (commented out - requires treesitter)
-- local render_md_ok, render_md = pcall(require, "render-markdown")
-- if render_md_ok then
--   render_md.setup({
--     enabled = true,
--     render_modes = { "n", "c" },
--   })
-- end

-- ============================================================================
-- KEY MAPPINGS
-- ============================================================================

-- General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", 'gb', '<C-o>', { desc = 'Go back' })

-- Window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "p", '"_dP')

-- Wrapped lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- File operations
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all" })

-- Plugin-specific keymaps (only if plugins loaded)
if tree_ok then
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
end

if telescope_ok then
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
end

if gitsigns_ok then
  vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
  vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Git blame line" })
  vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
  vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })
end

-- if obsidian_ok then
--   vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create new note" })
--   vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick switch notes" })
--   vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search notes" })
--   vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Open today's note" })
-- end

-- ============================================================================
-- AUTO COMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Markdown settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- ============================================================================
-- STATUS MESSAGE
-- ============================================================================

-- Show which plugins loaded successfully
vim.defer_fn(function()
  local loaded = {}
  if ok then table.insert(loaded, "catppuccin") end
  if tree_ok then table.insert(loaded, "nvim-tree") end
  if cmp_ok then table.insert(loaded, "nvim-cmp") end
  if telescope_ok then table.insert(loaded, "telescope") end
  -- if treesitter_ok then table.insert(loaded, "treesitter") end
  if gitsigns_ok then table.insert(loaded, "gitsigns") end
  -- if obsidian_ok then table.insert(loaded, "obsidian") end

  if #loaded > 0 then
    print("Loaded plugins: " .. table.concat(loaded, ", "))
  else
    print("No plugins loaded - using vanilla Neovim")
  end
end, 100)
