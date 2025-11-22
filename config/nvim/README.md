# Neovim Configuration

Three configurations are provided for different environments:

## Files

- **`init.lua`** - Full configuration (requires git)
- **`init-nogit.lua`** - Graceful fallback when git unavailable (uses lazy.nvim)
- **`init-simple.lua`** - No plugin manager, direct plugin loading

## Installation Options

### Option 1: With Git (Recommended)

If you have git/Xcode Command Line Tools:

```bash
# Copy standard config
cp init.lua ~/.config/nvim/init.lua

# Open Neovim (lazy.nvim will auto-install plugins)
nvim
```

### Option 2: Without Git - Using lazy.nvim (Recommended for no-git)

If you don't have git but want to use lazy.nvim:

```bash
# 1. Install plugins manually (including lazy.nvim)
chmod +x ../../scripts/install-nvim-plugins-with-curl.sh
../../scripts/install-nvim-plugins-with-curl.sh

# 2. Copy no-git config
cp init-nogit.lua ~/.config/nvim/init.lua

# 3. Open Neovim
nvim
```

### Option 3: Without Git - No Plugin Manager (Simplest)

If you want the simplest setup without lazy.nvim:

```bash
# 1. Install plugins manually
chmod +x ../../scripts/install-nvim-plugins-with-curl.sh
../../scripts/install-nvim-plugins-with-curl.sh

# 2. Copy simple config
cp init-simple.lua ~/.config/nvim/init.lua

# 3. Open Neovim
nvim
```

## Key Differences

### `init.lua` (Standard)
- ✅ Requires git for lazy.nvim to work
- ✅ Auto-downloads plugins on first run
- ✅ Auto-updates plugins
- ✅ Uses lazy.nvim plugin manager fully
- ❌ Won't work without git

### `init-nogit.lua` (Graceful No-Git)
- ✅ Detects if git is available
- ✅ Uses lazy.nvim with pre-installed plugins
- ✅ Falls back to defaults if plugins missing
- ✅ Each plugin wrapped in `pcall()` for graceful failure
- ✅ Disables auto-update features when no git
- ⚠️ Requires lazy.nvim to be installed (via curl script)

### `init-simple.lua` (No Plugin Manager)
- ✅ No dependency on lazy.nvim at all
- ✅ Directly loads plugins from `~/.local/share/nvim/lazy/`
- ✅ Simplest possible setup
- ✅ Each plugin wrapped in `pcall()` for graceful failure
- ✅ Works even if lazy.nvim install failed
- ⚠️ No plugin management features

## How It Works Together

**The curl install script** installs everything to `~/.local/share/nvim/lazy/`:
- `lazy.nvim` → Plugin manager itself
- `catppuccin/` → Colorscheme
- `nvim-tree.lua/` → File explorer
- `nvim-cmp/` → Completion engine
- And all other plugins...

**Config options:**
1. **init-nogit.lua** → Uses lazy.nvim with pre-downloaded plugins
2. **init-simple.lua** → Bypasses lazy.nvim, loads plugins directly

## Summary & Recommendation

**For office laptop without git:**

1. **Best option:** Use `init-simple.lua`
   - Doesn't depend on lazy.nvim working
   - Loads plugins directly from `~/.local/share/nvim/lazy/`
   - Most reliable for restricted environments

2. **Alternative:** Use `init-nogit.lua`
   - If you want lazy.nvim features
   - Requires lazy.nvim to be installed successfully

## What Gets Installed

✅ Script installs all plugins to the correct location (`~/.local/share/nvim/lazy/`)
✅ Lazy.nvim finds them automatically (if using init-nogit.lua)
✅ Or loaded directly (if using init-simple.lua)
✅ Script continues even if some plugins fail
✅ Neovim works even if some/all plugins failed to install

## Quick Decision Guide

**If lazy.nvim installation succeeded:**
→ Use `init-nogit.lua`

**If lazy.nvim installation failed:**
→ Use `init-simple.lua` (works without lazy.nvim!)
