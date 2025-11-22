-- ============================================================================
-- ~/.config/nvim/init.lua (No-Git Version)
-- ============================================================================
-- This version works when plugins are manually installed via curl
-- Falls back gracefully if git is not available

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
-- PYTHON CONFIGURATION
-- ============================================================================

-- Set Python path to use local venv if it exists
local venv_python = vim.fn.getcwd() .. '/.venv/bin/python'
if vim.fn.filereadable(venv_python) == 1 then
  vim.g.python3_host_prog = venv_python
end

-- ============================================================================
-- CHECK FOR GIT AND LAZY.NVIM
-- ============================================================================

local has_git = vim.fn.executable("git") == 1

-- Auto-install lazy.nvim if not present AND git is available
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_installed = (vim.uv or vim.loop).fs_stat(lazypath)

if not lazy_installed and has_git then
  print("Installing lazy.nvim...")
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
  lazy_installed = true
elseif not lazy_installed and not has_git then
  vim.notify("lazy.nvim not found and git is not available. Please install plugins manually.", vim.log.levels.WARN)
end

if lazy_installed then
  vim.opt.rtp:prepend(lazypath)
end

-- ============================================================================
-- PLUGIN SPECIFICATIONS
-- ============================================================================

if lazy_installed then
  require("lazy").setup({
    spec = {
      -- Colorscheme
      {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
          -- Check if plugin actually loaded
          local ok, catppuccin = pcall(require, "catppuccin")
          if ok then
            catppuccin.setup({
              flavour = "mocha",
              transparent_background = false,
            })
            vim.cmd.colorscheme("catppuccin")
          else
            vim.notify("Catppuccin not available, using default colorscheme", vim.log.levels.INFO)
          end
        end,
      },

      -- File Explorer
      {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          local ok, nvim_tree = pcall(require, "nvim-tree")
          if ok then
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            nvim_tree.setup({
              sort = { sorter = "case_sensitive" },
              view = { adaptive_size = true, side = "left" },
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
              filters = { dotfiles = false },
              git = { enable = true, ignore = false },
            })
          end
        end,
      },

      -- Completion engine
      {
        "hrsh7th/nvim-cmp",
        commit = "ae644feb7b67bf1ce4260c231d1d4300b19c6f30",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
        config = function()
          local ok, cmp = pcall(require, "cmp")
          if not ok then return end

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
            formatting = {
              format = function(entry, vim_item)
                vim_item.menu = ({
                  nvim_lsp = "[LSP]",
                  luasnip = "[Snippet]",
                  obsidian = "[Obsidian]",
                  buffer = "[Buffer]",
                  path = "[Path]",
                })[entry.source.name]
                return vim_item
              end,
            },
          })
        end,
      },

      -- Obsidian (commented out - uncomment if you use Obsidian)
      -- {
      --   "epwalsh/obsidian.nvim",
      --   version = "^3.0.0",
      --   dependencies = {
      --     "nvim-lua/plenary.nvim",
      --     "hrsh7th/nvim-cmp",
      --   },
      --   config = function()
      --     local ok, obsidian = pcall(require, "obsidian")
      --     if not ok then return end

      --     obsidian.setup({
      --       workspaces = {
      --         { name = "notes", path = "~/Documents/notes" },
      --       },
      --       daily_notes = {
      --         folder = "daily",
      --         date_format = "%Y-%m-%d",
      --         alias_format = "%B %-d, %Y",
      --         template = nil,
      --       },
      --       templates = {
      --         folder = "templates",
      --         date_format = "%Y-%m-%d",
      --         time_format = "%H:%M",
      --       },
      --       completion = {
      --         nvim_cmp = true,
      --         min_chars = 2,
      --       },
      --       mappings = {
      --         ["gf"] = {
      --           action = function()
      --             return require("obsidian").util.gf_passthrough()
      --           end,
      --           opts = { noremap = false, expr = true, buffer = true },
      --         },
      --         ["<leader>ch"] = {
      --           action = function()
      --             return require("obsidian").util.toggle_checkbox()
      --           end,
      --           opts = { buffer = true },
      --         },
      --         ["<cr>"] = {
      --           action = function()
      --             return require("obsidian").util.smart_action()
      --           end,
      --           opts = { buffer = true, expr = true },
      --         },
      --       },
      --       note_frontmatter_func = function(note)
      --         local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      --         if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
      --           for k, v in pairs(note.metadata) do
      --             out[k] = v
      --           end
      --         end
      --         return out
      --       end,
      --       ui = {
      --         enable = true,
      --         checkboxes = {
      --           [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      --           ["x"] = { char = "󰱒", hl_group = "ObsidianDone" },
      --           [">"] = { char = "", hl_group = "ObsidianRightArrow" },
      --           ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      --         },
      --         bullets = { char = "•", hl_group = "ObsidianBullet" },
      --         external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      --         reference_text = { hl_group = "ObsidianRefText" },
      --         highlight_text = { hl_group = "ObsidianHighlightText" },
      --         tags = { hl_group = "ObsidianTag" },
      --         block_ids = { hl_group = "ObsidianBlockID" },
      --         hl_groups = {
      --           ObsidianTodo = { bold = true, fg = "#f78c6c" },
      --           ObsidianDone = { bold = true, fg = "#89ddff" },
      --           ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
      --           ObsidianTilde = { bold = true, fg = "#ff5370" },
      --           ObsidianBullet = { bold = true, fg = "#89ddff" },
      --           ObsidianRefText = { underline = true, fg = "#c792ea" },
      --           ObsidianExtLinkIcon = { fg = "#c792ea" },
      --           ObsidianTag = { italic = true, fg = "#89ddff" },
      --           ObsidianBlockID = { italic = true, fg = "#89ddff" },
      --           ObsidianHighlightText = { bg = "#75662e" },
      --         },
      --       },
      --       attachments = {
      --         img_folder = "attachments",
      --       },
      --       preferred_link_style = "markdown",
      --       disable_frontmatter = false,
      --       note_id_func = function(title)
      --         local suffix = ""
      --         if title ~= nil then
      --           suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      --         else
      --           for _ = 1, 4 do
      --             suffix = suffix .. string.char(math.random(65, 90))
      --           end
      --         end
      --         return tostring(os.time()) .. "-" .. suffix
      --       end,
      --     })
      --   end
      -- },

      -- Fuzzy finder
      {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          local ok, telescope = pcall(require, "telescope")
          if not ok then return end

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
        end,
      },

      -- Syntax highlighting
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          local ok, treesitter = pcall(require, "nvim-treesitter.configs")
          if not ok then return end

          treesitter.setup({
            ensure_installed = {
              "lua", "vim", "vimdoc", "python", "javascript",
              "typescript", "html", "css", "json", "markdown", "markdown_inline"
            },
            auto_install = has_git,  -- Only auto-install if git is available
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
          local ok, gitsigns = pcall(require, "gitsigns")
          if not ok then return end

          gitsigns.setup({
            signs = {
              add          = { text = '│' },
              change       = { text = '│' },
              delete       = { text = '_' },
              topdelete    = { text = '‾' },
              changedelete = { text = '~' },
              untracked    = { text = '┆' },
            },
            signcolumn = true,
            numhl      = false,
            linehl     = false,
            word_diff  = false,
            watch_gitdir = {
              follow_files = true
            },
            attach_to_untracked = true,
            current_line_blame = false,
            current_line_blame_opts = {
              virt_text = true,
              virt_text_pos = 'eol',
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
        ft = "markdown",
        config = function()
          local ok, render_md = pcall(require, "render-markdown")
          if not ok then return end

          render_md.setup({
            enabled = true,
            render_modes = { "n", "c" },
            heading = {
              enabled = true,
              sign = true,
              icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
            },
            code = {
              enabled = true,
              sign = false,
              style = "full",
              border = "thin",
            },
            bullet = {
              enabled = true,
              icons = { "●", "○", "◆", "◇" },
            },
            checkbox = {
              enabled = true,
              unchecked = {
                icon = '󰄱 ',
                highlight = 'RenderMarkdownUnchecked',
              },
              checked = {
                icon = '󰱒 ',
                highlight = 'RenderMarkdownChecked',
              },
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

          vim.keymap.set("n", "<leader>mi", ":MoltenInit python3<CR>", { desc = "Initialize Molten" })
          vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Evaluate with operator" })
          vim.keymap.set("n", "<leader>rl", ":MoltenEvaluateLine<CR>", { desc = "Evaluate line" })
          vim.keymap.set("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate visual selection" })
          vim.keymap.set("n", "<leader>rd", ":MoltenDelete<CR>", { desc = "Delete Molten cell" })
          vim.keymap.set("n", "<leader>ro", ":MoltenShowOutput<CR>", { desc = "Show output" })
        end,
      },

      -- NotebookNavigator for cell navigation and execution
      {
        "GCBallesteros/NotebookNavigator.nvim",
        commit = "20cb6f72939194e32eb3060578b445e5f2e7ae8b",
        dependencies = { "benlubas/molten-nvim" },
        config = function()
          local ok, nn = pcall(require, "notebook-navigator")
          if not ok then return end

          nn.setup({
            activate_hydra_keys = "<leader>h",
            show_hydra_hint = true,
            repl_provider = "auto",
            cell_markers = {
              python = "# %%",
            },
          })

          vim.keymap.set("n", "<leader>rc", function() nn.run_cell() end, { desc = "Run cell" })
          vim.keymap.set("n", "<leader>rx", function() nn.run_and_move() end, { desc = "Run cell and move" })
          vim.keymap.set("n", "<leader>rj", function() nn.move_cell("d") end, { desc = "Move to next cell" })
          vim.keymap.set("n", "<leader>rk", function() nn.move_cell("u") end, { desc = "Move to previous cell" })
          vim.keymap.set("n", "<leader>ca", function() nn.add_cell_above() end, { desc = "Add cell above" })
          vim.keymap.set("n", "<leader>cb", function() nn.add_cell_below() end, { desc = "Add cell below" })
          vim.keymap.set("n", "<leader>cs", function() nn.split_cell() end, { desc = "Split cell" })
          vim.keymap.set("n", "<leader>cm", function() nn.merge_cell("d") end, { desc = "Merge with next cell" })
          vim.keymap.set("n", "<leader>cc", function() nn.comment_cell() end, { desc = "Comment cell" })
        end,
      },

      -- Jupytext for conversion
      {
        "GCBallesteros/jupytext.nvim",
        ft = "python",
        config = function()
          local ok, jupytext = pcall(require, "jupytext")
          if not ok then return end

          jupytext.setup({
            style = "percent",
            output_extension = "ipynb",
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
      colorscheme = { "catppuccin", "habamax" },
    },
    checker = {
      enabled = has_git,  -- Only check for updates if git is available
      notify = false,
    },
  })
else
  vim.notify("Running Neovim without lazy.nvim plugin manager", vim.log.levels.INFO)
end

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

-- Nvim-tree keymaps (only if nvim-tree is loaded)
if pcall(require, "nvim-tree") then
  vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
  vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
  vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeResize +10<CR>", { desc = "Increase tree width" })
  vim.keymap.set("n", "<leader>el", "<cmd>NvimTreeResize -10<CR>", { desc = "Decrease tree width" })
end

-- Telescope keymaps (only if telescope is loaded)
if pcall(require, "telescope") then
  local builtin = require("telescope.builtin")
  vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
end

-- Quick save
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Quick quit
vim.keymap.set("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Git keymaps (only if gitsigns is loaded)
if pcall(require, "gitsigns") then
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
end

-- Obsidian keymaps (commented out - uncomment if you use Obsidian)
-- if pcall(require, "obsidian") then
--   vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create new note" })
--   vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick switch notes" })
--   vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search notes" })
--   vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianToday<CR>", { desc = "Open today's note" })
--   vim.keymap.set("n", "<leader>oy", "<cmd>ObsidianYesterday<CR>", { desc = "Open yesterday's note" })
--   vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show backlinks" })
--   vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Show links" })
--   vim.keymap.set("n", "<leader>otg", "<cmd>ObsidianTags<CR>", { desc = "Show tags" })
--   vim.keymap.set("n", "<leader>oT", "<cmd>ObsidianTemplate<CR>", { desc = "Insert template" })
--   vim.keymap.set("n", "<leader>or", "<cmd>ObsidianRename<CR>", { desc = "Rename note" })
--   vim.keymap.set("v", "<leader>ol", "<cmd>ObsidianLinkNew<CR>", { desc = "Link to new note" })
--   vim.keymap.set("v", "<leader>oe", "<cmd>ObsidianExtractNote<CR>", { desc = "Extract to new note" })
-- end

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

-- Open nvim-tree automatically when starting Neovim (only if plugin loaded)
if pcall(require, "nvim-tree") then
  vim.api.nvim_create_autocmd("VimEnter", {
    desc = "Open nvim-tree on startup",
    group = vim.api.nvim_create_augroup("nvim-tree-start", { clear = true }),
    callback = function(data)
      local directory = vim.fn.isdirectory(data.file) == 1
      local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

      if directory or no_name then
        require("nvim-tree.api").tree.open()
      end
    end,
  })
end

-- Markdown-specific settings
vim.api.nvim_create_autocmd("FileType", {
  desc = "Markdown-specific settings for better reading",
  group = vim.api.nvim_create_augroup("markdown-settings", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldenable = false
    vim.opt_local.foldlevel = 99
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Jupytext auto-sync
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Auto-create paired .ipynb for .py files with cell markers",
  group = vim.api.nvim_create_augroup("jupytext-sync", { clear = true }),
  pattern = "*.py",
  callback = function()
    local file = vim.fn.expand("%:p")
    local ipynb_file = vim.fn.expand("%:p:r") .. ".ipynb"

    local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
    local has_cells = false
    for _, line in ipairs(lines) do
      if line:match("^# %%") then
        has_cells = true
        break
      end
    end

    if has_cells and vim.fn.filereadable(ipynb_file) == 0 then
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
