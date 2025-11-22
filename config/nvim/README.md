# Neovim Configuration

Two configurations are provided for different environments:

## Files

- **`init.lua`** - Full configuration (requires git)
- **`init-nogit.lua`** - No-git version (works without git)

## Installation Options

### Option 1: With Git (Recommended)

If you have git/Xcode Command Line Tools:

```bash
# Copy standard config
cp init.lua ~/.config/nvim/init.lua

# Open Neovim (lazy.nvim will auto-install plugins)
nvim
```

### Option 2: Without Git (Office Laptop)

If you don't have git:

```bash
# 1. Install plugins manually
chmod +x ../../scripts/install-nvim-plugins-with-curl.sh
../../scripts/install-nvim-plugins-with-curl.sh

# 2. Copy no-git config
cp init-nogit.lua ~/.config/nvim/init.lua

# 3. Open Neovim
nvim
```

## Key Differences

### `init.lua` (Standard)
- Requires git for lazy.nvim to work
- Auto-downloads plugins on first run
- Auto-updates plugins
- Uses lazy.nvim plugin manager fully

### `init-nogit.lua` (No-Git Version)
- Detects if git is available
- Uses manually installed plugins gracefully
- Falls back to defaults if plugins missing
- Each plugin wrapped in `pcall()` for graceful failure
- Disables auto-update features when no git

## How It Works Together

**The curl install script** installs plugins to:
- `~/.local/share/nvim/site/pack/plugins/start/` (auto-loaded by Neovim)
- `~/.local/share/nvim/lazy/lazy.nvim` (lazy.nvim itself)

**The no-git init.lua:**
1. Checks if git exists
2. Uses manually installed lazy.nvim if found
3. Each plugin config wrapped in `pcall()` for graceful failure
4. Keymaps only set if plugins actually loaded
5. Falls back to basic Neovim if no plugins

## Summary

**Both installations work:**
- Curl script → plugins manually downloaded
- No-git init.lua → uses those plugins
- If plugin missing → gracefully skips it
- **You don't need a separate init.lua** - the no-git version handles both cases!

## Result

✅ Script fails gracefully (continues installing other plugins)
✅ Single init.lua works for both manual and git installations
✅ Neovim works even if some/all plugins failed to install
✅ No errors, just warnings for missing plugins
