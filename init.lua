-- ============================================================================
-- ~/.config/nvim/init.lua
-- ============================================================================

-- ============================================================================
-- BASIC SETTINGS
-- ============================================================================

-- Line numbers
vim.opt.number = true              -- Show absolute line numbers
vim.opt.relativenumber = true      -- Show relative line numbers

-- Indentation (using 2 spaces to match your existing config)
vim.opt.tabstop = 2                -- Number of spaces a <Tab> counts for
vim.opt.softtabstop = 2            -- Number of spaces for <Tab> in insert mode
vim.opt.shiftwidth = 2             -- Number of spaces for each indentation level
vim.opt.expandtab = true           -- Convert tabs to spaces
vim.opt.smartindent = true         -- Smart autoindenting on new lines

--- Code Folding
vim.o.foldmethod = "indent"
vim.o.foldlevel = 4

-- Search
vim.opt.ignorecase = true          -- Ignore case in search patterns
vim.opt.smartcase = true           -- Override ignorecase if search has uppercase
vim.opt.hlsearch = true            -- Highlight search matches
vim.opt.incsearch = true           -- Show matches as you type

-- UI
vim.opt.termguicolors = true       -- Enable 24-bit RGB colors
vim.opt.cursorline = true          -- Highlight the current line
vim.opt.wrap = true                -- Wrap long lines visually
vim.opt.linebreak = true           -- Break lines at word boundaries (not mid-word)
vim.opt.scrolloff = 8              -- Keep 8 lines visible above/below cursor
vim.opt.signcolumn = "yes"         -- Always show sign column (prevents text shift)

-- Behavior
vim.opt.mouse = "a"                -- Enable mouse in all modes
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.opt.undofile = true            -- Enable persistent undo
vim.opt.swapfile = false           -- Disable swap file
vim.opt.backup = false             -- Disable backup file
vim.opt.updatetime = 250           -- Faster completion
vim.opt.timeoutlen = 300           -- Time to wait for mapped sequence

-- Splits
vim.opt.splitright = true          -- Vertical splits open to the right
vim.opt.splitbelow = true          -- Horizontal splits open below

-- ============================================================================
-- LEADER KEYS (Must be set before lazy.nvim)
-- ============================================================================

vim.g.mapleader = " "              -- Space as leader key
vim.g.maplocalleader = "\\"        -- Backslash as local leader

-- ============================================================================
-- LAZY.NVIM PLUGIN MANAGER BOOTSTRAP
-- ============================================================================

-- Auto-install lazy.nvim if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGIN SPECIFICATIONS
-- ============================================================================

require("lazy").setup({
  spec = {
    -- Colorscheme
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,              -- Load first
      config = function()
        require("catppuccin").setup({
          flavour = "mocha",         -- mocha, macchiato, frappe, latte
          transparent_background = false,
        })
        vim.cmd.colorscheme("catppuccin")
      end,
    },

    -- File Explorer
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        -- Disable netrw (Vim's built-in file explorer)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-tree").setup({
          sort = {
            sorter = "case_sensitive",
          },
          view = {
            adaptive_size = true,      -- Dynamic width based on content
            side = "left",
          },
          renderer = {
            group_empty = true,
            icons = {
              show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
              },
            },
          },
          filters = {
            dotfiles = false,         -- Show hidden files
          },
          git = {
            enable = true,
            ignore = false,            -- Show gitignored files
          },
        })
      end,
    },

    -- Obsidian
    {
      "epwalsh/obsidian.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("obsidian").setup({
          workspaces = {
            { name = "notes", path = "~/Documents/notes" },
          },
        })
      end
    } ,

    -- Fuzzy finder
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup({
          defaults = {
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
              },
            },
          },
        })
      end,
    },

    -- Syntax highlighting
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "lua", "vim", "vimdoc", "python", "javascript",
            "typescript", "html", "css", "json", "markdown", "markdown_inline"
          },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end,
    },

    -- Git integration
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          signs = {
            add          = { text = '│' },
            change       = { text = '│' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
          numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
          linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
          word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
          watch_gitdir = {
            follow_files = true
          },
          attach_to_untracked = true,
          current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
          },
          sign_priority = 6,
          update_debounce = 100,
          status_formatter = nil,
          max_file_length = 40000,
          preview_config = {
            border = 'single',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
          },
        })
      end,
    },

    -- Markdown rendering
    {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
      ft = "markdown",                -- Only load for markdown files
      config = function()
        require("render-markdown").setup({
          enabled = true,
          render_modes = { "n", "c" }, -- Render in normal and command mode
          heading = {
            enabled = true,
            sign = true,
            icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
          },
          code = {
            enabled = true,
            sign = false,
            style = "full",            -- Full-width code blocks
            border = "thin",
          },
          bullet = {
            enabled = true,
            icons = { "●", "○", "◆", "◇" },
          },
        })
      end,
    },

    -- Molten for interactive execution
    {
      "benlubas/molten-nvim",
      version = "^1.0.0",
      build = ":UpdateRemotePlugins",
      dependencies = { "3rd/image.nvim" },
      config = function()
        vim.g.molten_auto_open_output = false
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_wrap_output = true
        vim.g.molten_virt_text_output = true

        -- Keymaps
        vim.keymap.set("n", "<leader>mi", ":MoltenInit python3<CR>")
        vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>")
        vim.keymap.set("n", "<leader>rr", ":MoltenEvaluateOperator<CR>", { desc = "Evaluate current cell" })
        vim.keymap.set("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv")
        vim.keymap.set("n", "<leader>rd", ":MoltenDelete<CR>")
        vim.keymap.set("n", "<leader>ro", ":MoltenShowOutput<CR>")
      end,
    },

    -- Jupytext for conversion
    {
      "GCBallesteros/jupytext.nvim",
      ft = "python",  -- Only load for Python files, not .ipynb
      config = function()
        require("jupytext").setup({
          style = "percent",
          output_extension = "ipynb",  -- Create paired .ipynb file
          force_ft = "python",
          custom_language_formatting = {
            python = {
              extension = "py",
              style = "percent",
              force_ft = "python",
            },
          },
        })
      end,
    },

    -- Image support (optional, needs Kitty terminal)
    {
      "3rd/image.nvim",
      opts = {
        backend = "kitty",
      },
    },
  },

  -- Settings for lazy.nvim itself
  install = {
    colorscheme = { "catppuccin", "habamax" },  -- Try catppuccin, fallback to habamax
  },
  checker = {
    enabled = true,                -- Auto-check for plugin updates
    notify = false,                -- Don't notify about updates
  },
})

-- ============================================================================
-- KEY MAPPINGS
-- ============================================================================

-- General
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", 'gb', '<C-o>', { desc = 'Go back' })

-- Better window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Stay in visual mode when indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better paste (don't yank replaced text)
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Toggle line wrap
vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrap" })

-- Better navigation for wrapped lines
vim.keymap.set("n", "j", "gj", { desc = "Move down (display line)" })
vim.keymap.set("n", "k", "gk", { desc = "Move up (display line)" })
vim.keymap.set("n", "gj", "j", { desc = "Move down (logical line)" })
vim.keymap.set("n", "gk", "k", { desc = "Move up (logical line)" })

-- Nvim-tree keymaps
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeResize +10<CR>", { desc = "Increase tree width" })
vim.keymap.set("n", "<leader>el", "<cmd>NvimTreeResize -10<CR>", { desc = "Decrease tree width" })

-- Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })

-- Quick save
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Quick quit (quit all windows)
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Git keymaps (gitsigns)
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Git blame line" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Unstage hunk" })
vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })
vim.keymap.set("n", "<leader>gtd", "<cmd>Gitsigns toggle_deleted<CR>", { desc = "Toggle deleted lines" })

-- ============================================================================
-- AUTO COMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  group = vim.api.nvim_create_augroup("trim-whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Open nvim-tree automatically when starting Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open nvim-tree on startup",
  group = vim.api.nvim_create_augroup("nvim-tree-start", { clear = true }),
  callback = function(data)
    -- Check if we opened a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    -- Check if we opened with no arguments
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if directory or no_name then
      -- Open the tree
      require("nvim-tree.api").tree.open()
    end
  end,
})

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  desc = "Markdown-specific settings for better reading",
  group = vim.api.nvim_create_augroup("markdown-settings", { clear = true }),
  pattern = "markdown",
  callback = function()
    -- Concealment settings (required for render-markdown.nvim)
    vim.opt_local.conceallevel = 2         -- Enable concealment
    vim.opt_local.concealcursor = ""       -- Show concealed text on cursor line

    -- Spell checking
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"

    -- Folding with treesitter
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldenable = false       -- Don't fold by default
    vim.opt_local.foldlevel = 99           -- Open all folds initially

    -- Text wrapping (inherit from global settings, ensure they're set)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true       -- Indent wrapped lines
  end,
})

-- Jupytext auto-sync: create paired .ipynb when opening .py with cell markers
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Auto-create paired .ipynb for .py files with cell markers",
  group = vim.api.nvim_create_augroup("jupytext-sync", { clear = true }),
  pattern = "*.py",
  callback = function()
    local file = vim.fn.expand("%:p")
    local ipynb_file = vim.fn.expand("%:p:r") .. ".ipynb"

    -- Check if file has cell markers and .ipynb doesn't exist
    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
    local has_cells = false
    for _, line in ipairs(lines) do
      if line:match("^# %%") then
        has_cells = true
        break
      end
    end

    if has_cells and vim.fn.filereadable(ipynb_file) == 0 then
      -- Create paired .ipynb file using jupytext
      vim.fn.system(string.format("jupytext --to ipynb '%s'", file))
      print("Created paired notebook: " .. vim.fn.fnamemodify(ipynb_file, ":t"))
    end
  end,
})

-- Jupytext manual sync keymap
vim.keymap.set("n", "<leader>js", function()
  local file = vim.fn.expand("%:p")
  if vim.bo.filetype == "python" then
    vim.fn.system(string.format("jupytext --to ipynb '%s'", file))
    print("Synced to .ipynb")
  else
    print("Not a Python file")
  end
end, { desc = "Jupytext sync to .ipynb" })

-- ============================================================================
-- END OF CONFIG
-- ============================================================================
