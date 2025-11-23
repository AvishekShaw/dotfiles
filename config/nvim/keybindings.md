# Neovim Keybindings Reference

**Leader Key:** `<Space>`
**Local Leader Key:** `\`

---

## General Navigation

| Key | Mode | Action |
|-----|------|--------|
| `j` / `k` | Normal | Move down/up by display line (wrapping-aware) |
| `gj` / `gk` | Normal | Move down/up by logical line |
| `h` / `l` | Normal | Move left/right |
| `gg` | Normal | Go to top of file |
| `G` | Normal | Go to bottom of file |
| `gb` | Normal | Go back (jump to previous location) |
| `<Esc>` | Normal | Clear search highlights |

---

## Window Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>h` | Normal | Move to left window |
| `<leader>j` | Normal | Move to bottom window |
| `<leader>k` | Normal | Move to top window |
| `<leader>l` | Normal | Move to right window |
| `<C-Up>` | Normal | Increase window height |
| `<C-Down>` | Normal | Decrease window height |
| `<C-Left>` | Normal | Decrease window width |
| `<C-Right>` | Normal | Increase window width |

---

## File Operations

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | Normal | Save file |
| `<leader>q` | Normal | Quit all windows |
| `<leader>Q` | Normal | Force quit all windows |

---

## File Explorer (nvim-tree)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | Normal | Toggle file explorer |
| `<leader>ef` | Normal | Focus file explorer |
| `<leader>ec` | Normal | Collapse file explorer |
| `<leader>er` | Normal | Increase tree width |
| `<leader>el` | Normal | Decrease tree width |

### Inside File Explorer

| Key | Action |
|-----|--------|
| `<CR>` | Open file/folder |
| `o` | Open file/folder |
| `a` | Create new file |
| `d` | Delete file |
| `r` | Rename file |
| `x` | Cut file |
| `c` | Copy file |
| `p` | Paste file |
| `y` | Copy filename |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |
| `R` | Refresh |
| `H` | Toggle hidden files |
| `I` | Toggle git ignored files |
| `q` | Close tree |

---

## Fuzzy Finder (Telescope)

| Key | Mode | Action |
|-----|------|--------|
| `<C-p>` | Normal | Find files |
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep (search in files) |
| `<leader>fb` | Normal | Find buffers |
| `<leader>fh` | Normal | Find help tags |

### Inside Telescope

| Key | Action |
|-----|--------|
| `<C-j>` / `<C-k>` | Move selection down/up |
| `<CR>` | Open selected item |
| `<C-x>` | Open in horizontal split |
| `<C-v>` | Open in vertical split |
| `<C-t>` | Open in new tab |
| `<Esc>` | Close telescope |

---

## Visual Mode

| Key | Mode | Action |
|-----|------|--------|
| `<` | Visual | Indent left (stay in visual mode) |
| `>` | Visual | Indent right (stay in visual mode) |
| `J` | Visual | Move selected line(s) down |
| `K` | Visual | Move selected line(s) up |
| `p` | Visual | Paste without yanking replaced text |

---

## Text Editing

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tw` | Normal | Toggle line wrap |

---

## Git Integration (Gitsigns)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gp` | Normal | Preview git hunk |
| `<leader>gb` | Normal | Git blame line |
| `<leader>gd` | Normal | Git diff |
| `<leader>gr` | Normal | Reset hunk |
| `<leader>gs` | Normal | Stage hunk |
| `<leader>gu` | Normal | Unstage hunk |
| `]c` | Normal | Next git hunk |
| `[c` | Normal | Previous git hunk |
| `<leader>gtb` | Normal | Toggle git blame |
| `<leader>gtd` | Normal | Toggle deleted lines |

---

## Obsidian Note Taking

**Note:** All Obsidian commands use `<leader>n` prefix (for "notes")

| Key | Mode | Action |
|-----|------|--------|
| `<leader>nn` | Normal | Create new note |
| `<leader>no` | Normal | Quick switch notes |
| `<leader>ns` | Normal | Search notes |
| `<leader>nd` | Normal | Open today's note (daily) |
| `<leader>ny` | Normal | Open yesterday's note |
| `<leader>nb` | Normal | Show backlinks |
| `<leader>nl` | Normal | Show links |
| `<leader>ng` | Normal | Show tags |
| `<leader>nt` | Normal | Insert template |
| `<leader>nr` | Normal | Rename note |
| `<leader>nl` | Visual | Link to new note |
| `<leader>ne` | Visual | Extract to new note |
| `<leader>nfv` | Normal | Follow link in vertical split |
| `<leader>nfh` | Normal | Follow link in horizontal split |
| `]n` | Normal | Jump to next link |
| `[n` | Normal | Jump to previous link |
| `<leader>ch` | Normal | Toggle checkbox (in markdown) |
| `gf` | Normal | Follow link under cursor |
| `<CR>` | Normal | Smart action (follow link/toggle checkbox) |

---

## Python Notebook (Molten + NotebookNavigator)

### Molten - Interactive Execution

| Key | Mode | Action |
|-----|------|--------|
| `<leader>mi` | Normal | Initialize Molten (Python3) |
| `<leader>me` | Normal | Evaluate with operator |
| `<leader>rl` | Normal | Evaluate/run line |
| `<leader>r` | Visual | Evaluate visual selection |
| `<leader>rd` | Normal | Delete Molten cell |
| `<leader>ro` | Normal | Show output |

### NotebookNavigator - Cell Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>h` | Normal | Activate Hydra mode (cell navigation) |
| `<leader>rc` | Normal | Run current cell |
| `<leader>rx` | Normal | Run cell and move to next |
| `<leader>rj` | Normal | Move to next cell |
| `<leader>rk` | Normal | Move to previous cell |
| `<leader>ca` | Normal | Add cell above |
| `<leader>cb` | Normal | Add cell below |
| `<leader>cs` | Normal | Split cell |
| `<leader>cm` | Normal | Merge with next cell |
| `<leader>cc` | Normal | Comment cell |

### Jupytext - Notebook Sync

| Key | Mode | Action |
|-----|------|--------|
| `<leader>js` | Normal | Sync Python file to .ipynb |

---

## Autocompletion (nvim-cmp)

| Key | Mode | Action |
|-----|------|--------|
| `<C-Space>` | Insert | Trigger completion |
| `<CR>` | Insert | Confirm selection |
| `<Tab>` | Insert | Next completion item / expand snippet |
| `<S-Tab>` | Insert | Previous completion item |
| `<C-b>` | Insert | Scroll docs up |
| `<C-f>` | Insert | Scroll docs down |
| `<C-e>` | Insert | Abort completion |

---

## Code Folding

| Key | Mode | Action |
|-----|------|--------|
| `za` | Normal | Toggle fold under cursor |
| `zA` | Normal | Toggle all folds under cursor |
| `zc` | Normal | Close fold under cursor |
| `zC` | Normal | Close all folds under cursor |
| `zo` | Normal | Open fold under cursor |
| `zO` | Normal | Open all folds under cursor |
| `zM` | Normal | Close all folds |
| `zR` | Normal | Open all folds |

---

## Plugin Information

### Installed Plugins

- **catppuccin/nvim** - Color scheme (Mocha flavor)
- **nvim-tree/nvim-tree.lua** - File explorer
- **nvim-telescope/telescope.nvim** - Fuzzy finder
- **nvim-treesitter/nvim-treesitter** - Syntax highlighting
- **hrsh7th/nvim-cmp** - Autocompletion
- **lewis6991/gitsigns.nvim** - Git integration
- **epwalsh/obsidian.nvim** - Obsidian note taking
- **MeanderingProgrammer/render-markdown.nvim** - Markdown rendering
- **benlubas/molten-nvim** - Interactive code execution
- **GCBallesteros/NotebookNavigator.nvim** - Jupyter-style cell navigation
- **GCBallesteros/jupytext.nvim** - Python ↔ Jupyter notebook conversion

---

## Features Enabled

- **Line numbers**: Absolute + relative
- **Smart indentation**: 2 spaces, auto-indent
- **Code folding**: Based on indentation (level 4)
- **Case-insensitive search**: Smart case matching
- **24-bit colors**: True color support
- **Cursor line highlighting**
- **Line wrapping**: At word boundaries
- **System clipboard**: Unified with Neovim
- **Persistent undo**: Survives restarts
- **No swap/backup files**
- **Mouse support**: All modes
- **Auto-save whitespace removal**
- **Highlight on yank**
- **Auto-open file tree**: When starting with directory

---

## Markdown-Specific Features

When editing markdown files:
- **Spell checking**: Enabled (US English)
- **Concealment**: Level 2 (hides syntax, shows on cursor line)
- **Folding**: Treesitter-based, all folds open by default
- **Line wrapping**: Enabled with breakindent
- **Rendering**: Live rendering with render-markdown.nvim

---

## Python-Specific Features

- **Cell markers**: `# %%` for Jupyter-style cells
- **Auto-sync**: Creates paired .ipynb for .py files with cells
- **Virtual environment**: Auto-detects `.venv/bin/python`
- **Interactive execution**: Run cells/selections with Molten
