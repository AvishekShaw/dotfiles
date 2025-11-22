# Neovim Plugin Update System (No Git Required)

A complete update management system for Neovim plugins installed via curl.

## Scripts

### 1. `install-nvim-plugins-with-curl.sh`
Initial installation of all plugins.

**What it does:**
- Downloads plugins from GitHub as tar.gz files
- Installs to `~/.local/share/nvim/lazy/`
- Saves commit hash in each plugin folder (`.git-commit` file)
- Works without git

### 2. `check-nvim-updates.sh`
Checks for available updates.

**Usage:**
```bash
./check-nvim-updates.sh
```

**What it does:**
- Compares local commit hash with latest GitHub commit
- Shows which plugins have updates available
- No modifications, just checks

**Example output:**
```
Checking catppuccin... ✓ Up to date (a1b2c3d)
Checking nvim-tree.lua... ⚠ Update available (local: abc123 → remote: def456)
Checking telescope.nvim... ✓ Up to date (9e8f7g6)

========================================
3 update(s) available

To update plugins, run:
  ./update-nvim-plugins.sh

To update specific plugins:
  ./update-nvim-plugins.sh nvim-tree.lua
========================================
```

### 3. `update-nvim-plugins.sh`
Updates plugins with automatic backup.

**Usage:**
```bash
# Update all plugins
./update-nvim-plugins.sh

# Update specific plugin
./update-nvim-plugins.sh nvim-tree.lua

# Update specific plugin (force)
./update-nvim-plugins.sh nvim-tree.lua --force
```

**What it does:**
1. **Creates backup** - Saves current plugin to `~/.config/nvim/backup/`
2. **Downloads update** - Gets latest version from GitHub
3. **Installs update** - Replaces old version
4. **Auto-rollback** - Restores from backup if update fails
5. **Cleans backups** - Keeps last 5 backups per plugin

## How It Works

### Version Tracking

Each plugin folder contains a `.git-commit` file:
```
~/.local/share/nvim/lazy/
├── nvim-tree.lua/
│   ├── .git-commit          <- Contains: abc123def456...
│   ├── lua/
│   └── plugin/
├── catppuccin/
│   ├── .git-commit          <- Contains: 789xyz...
│   └── ...
```

### Update Check Process

1. Read local commit from `.git-commit` file
2. Fetch latest commit from GitHub API:
   ```bash
   curl -s "https://api.github.com/repos/USER/REPO/commits/main"
   ```
3. Compare local vs remote commit hash
4. Report if update available

### Update Process

```
┌─────────────────────┐
│ Check for update    │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Create backup       │  ~/.config/nvim/backup/nvim-tree_20251122_143022.tar.gz
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Download new        │  GitHub → /tmp/nvim-tree_update.tar.gz
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Extract & install   │  /tmp → ~/.local/share/nvim/lazy/nvim-tree.lua/
└──────┬──────────────┘
       │
       ▼ Success?
       │
  ┌────┴────┐
  │ YES     │ NO
  │         │
  ▼         ▼
Update     Restore
commit     from backup
hash
```

## Safety Features

### Automatic Backups

Every update creates a timestamped backup:
```
~/.config/nvim/backup/
├── nvim-tree.lua_20251122_143022.tar.gz
├── nvim-tree.lua_20251122_150315.tar.gz
├── catppuccin_20251122_143025.tar.gz
└── ...
```

**Automatic cleanup:** Keeps last 5 backups per plugin

### Auto-Rollback

If update fails (download error, extraction error, etc.):
1. Detects failure
2. Automatically restores from backup
3. Reports error
4. Plugin remains functional

### Manual Restore

To manually restore a plugin:
```bash
# List backups
ls -lh ~/.config/nvim/backup/

# Restore manually
cd ~/.local/share/nvim/lazy
rm -rf nvim-tree.lua
tar -xzf ~/.config/nvim/backup/nvim-tree.lua_20251122_143022.tar.gz
```

## Dependency Handling

**Q: How are dependencies tracked?**

A: Each plugin is independent. The script updates plugins individually, not as a dependency tree.

**Q: What if a plugin update requires a newer dependency?**

A:
1. Update all plugins: `./update-nvim-plugins.sh`
2. Check Neovim for errors: `nvim`
3. Run `:checkhealth` to see issues
4. If there's an incompatibility, restore the problematic plugin:
   ```bash
   ./restore-nvim-plugin.sh nvim-cmp
   ```

## Usage Workflow

### Weekly Check (Recommended)

```bash
# 1. Check for updates
cd ~/dotfiles/scripts
./check-nvim-updates.sh

# 2. If updates available, review what will be updated
# (The check script lists all plugins with updates)

# 3. Update all or specific plugins
./update-nvim-plugins.sh              # Update all
# OR
./update-nvim-plugins.sh telescope.nvim   # Update specific

# 4. Test Neovim
nvim

# 5. If something broke, restore
# (Backups are in ~/.config/nvim/backup/)
```

### Monthly Full Update

```bash
# Update everything
./update-nvim-plugins.sh

# Test thoroughly
nvim
:checkhealth

# If issues, restore specific plugins
tar -xzf ~/.config/nvim/backup/PLUGIN_NAME_TIMESTAMP.tar.gz -C ~/.local/share/nvim/lazy/
```

## Breaking Changes

**Q: What if an update has breaking changes?**

**A:**
1. Neovim will show errors when loading
2. Restore from backup:
   ```bash
   cd ~/.local/share/nvim/lazy
   rm -rf problematic-plugin/
   tar -xzf ~/.config/nvim/backup/problematic-plugin_TIMESTAMP.tar.gz
   ```
3. Check plugin's GitHub for migration guide
4. Update your `init.lua` configuration
5. Try updating again

## Automation

### Cron Job (Optional)

Check for updates weekly:

```bash
# Add to crontab
crontab -e

# Add this line (runs every Monday at 9 AM)
0 9 * * 1 /Users/YOUR_USER/dotfiles/scripts/check-nvim-updates.sh > /tmp/nvim-update-check.log 2>&1
```

**Don't auto-update!** Only auto-check, then manually review and update.

## Troubleshooting

### "Failed to fetch remote"

**Cause:** GitHub API rate limit or network issue

**Solution:**
```bash
# Check if you can reach GitHub
curl -I https://api.github.com

# Check rate limit
curl -s https://api.github.com/rate_limit

# Wait and try again later
```

### "Unknown version"

**Cause:** Plugin installed before commit tracking was added

**Solution:**
```bash
# Reinstall to get version tracking
./update-nvim-plugins.sh plugin-name --force
```

### "Backup failed"

**Cause:** Disk full or permission issue

**Solution:**
```bash
# Check disk space
df -h

# Check backup directory permissions
ls -ld ~/.config/nvim/backup

# Clean old backups manually
rm ~/.config/nvim/backup/*_older_than_month.tar.gz
```

## Comparison with Git-Based Updates

| Feature | curl-based (this) | git-based (lazy.nvim) |
|---------|-------------------|----------------------|
| **Requires git** | ❌ No | ✅ Yes |
| **Update check** | Manual script | Automatic (`:Lazy check`) |
| **Update command** | `./update-nvim-plugins.sh` | `:Lazy update` |
| **Automatic backup** | ✅ Yes | ❌ No (rollback via git) |
| **Dependency tracking** | ❌ Manual | ✅ Automatic |
| **Speed** | Moderate (downloads full archive) | Fast (git fetch) |
| **Reliability** | High (works without git) | Higher (proper version control) |
| **Rollback** | Restore from tar.gz | `git checkout` |

## Summary

✅ **Check updates:** `./check-nvim-updates.sh`
✅ **Update all:** `./update-nvim-plugins.sh`
✅ **Update one:** `./update-nvim-plugins.sh plugin-name`
✅ **Automatic backups:** `~/.config/nvim/backup/`
✅ **Auto-rollback on failure**
✅ **No git required**
✅ **Safe and reversible**

## Files Created

- `check-nvim-updates.sh` - Check for updates
- `update-nvim-plugins.sh` - Update with backup
- `install-nvim-plugins-with-curl.sh` - Initial install (updated for version tracking)
- Each plugin's `.git-commit` file - Version tracking
