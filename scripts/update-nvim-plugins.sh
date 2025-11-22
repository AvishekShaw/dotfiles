#!/bin/bash
# ============================================================================
# Update Neovim Plugins (curl-only)
# ============================================================================
# Updates plugins installed via curl, with automatic backup

set +e  # Don't exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGIN_DIR="$HOME/.local/share/nvim/lazy"
BACKUP_DIR="$HOME/.config/nvim/backup"

# Plugin list with their repos and branches
declare -A PLUGINS=(
  ["lazy.nvim"]="folke/lazy.nvim:stable"
  ["plenary.nvim"]="nvim-lua/plenary.nvim:master"
  ["nvim-web-devicons"]="nvim-tree/nvim-web-devicons:master"
  ["catppuccin"]="catppuccin/nvim:main"
  ["nvim-tree.lua"]="nvim-tree/nvim-tree.lua:master"
  ["nvim-cmp"]="hrsh7th/nvim-cmp:master"
  ["cmp-nvim-lsp"]="hrsh7th/cmp-nvim-lsp:master"
  ["cmp-buffer"]="hrsh7th/cmp-buffer:master"
  ["cmp-path"]="hrsh7th/cmp-path:master"
  ["LuaSnip"]="L3MON4D3/LuaSnip:master"
  ["cmp_luasnip"]="saadparwaiz1/cmp_luasnip:master"
  ["friendly-snippets"]="rafamadriz/friendly-snippets:master"
  ["obsidian.nvim"]="epwalsh/obsidian.nvim:main"
  ["telescope.nvim"]="nvim-telescope/telescope.nvim:master"
  ["nvim-treesitter"]="nvim-treesitter/nvim-treesitter:master"
  ["gitsigns.nvim"]="lewis6991/gitsigns.nvim:main"
  ["render-markdown.nvim"]="MeanderingProgrammer/render-markdown.nvim:main"
  ["molten-nvim"]="benlubas/molten-nvim:main"
  ["NotebookNavigator.nvim"]="GCBallesteros/NotebookNavigator.nvim:main"
  ["jupytext.nvim"]="GCBallesteros/jupytext.nvim:main"
  ["image.nvim"]="3rd/image.nvim:master"
)

# Parse arguments
SPECIFIC_PLUGIN=""
FORCE_UPDATE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --force|-f)
      FORCE_UPDATE=true
      shift
      ;;
    --all|-a)
      SPECIFIC_PLUGIN=""
      shift
      ;;
    *)
      SPECIFIC_PLUGIN="$1"
      shift
      ;;
  esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Neovim Plugin Updater${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ ! -d "$PLUGIN_DIR" ]; then
  echo -e "${RED}Error: Plugin directory not found: $PLUGIN_DIR${NC}"
  exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup a plugin
backup_plugin() {
  local plugin_name=$1
  local plugin_dir="$PLUGIN_DIR/$plugin_name"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="$BACKUP_DIR/${plugin_name}_${timestamp}.tar.gz"

  if [ -d "$plugin_dir" ]; then
    echo -e "${BLUE}  Creating backup: ${plugin_name}_${timestamp}.tar.gz${NC}"
    tar -czf "$backup_path" -C "$PLUGIN_DIR" "$plugin_name" 2>/dev/null
    if [ $? -eq 0 ]; then
      echo "$backup_path"
      return 0
    else
      echo -e "${RED}  Failed to create backup${NC}"
      return 1
    fi
  else
    echo -e "${YELLOW}  Plugin not installed, skipping backup${NC}"
    return 1
  fi
}

# Function to restore a plugin from backup
restore_plugin() {
  local backup_path=$1
  local plugin_name=$2

  echo -e "${YELLOW}  Restoring from backup...${NC}"
  tar -xzf "$backup_path" -C "$PLUGIN_DIR" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Restored successfully${NC}"
    return 0
  else
    echo -e "${RED}  ✗ Failed to restore${NC}"
    return 1
  fi
}

# Function to update a plugin
update_plugin() {
  local plugin_name=$1
  local repo=$2
  local branch=$3
  local plugin_dir="$PLUGIN_DIR/$plugin_name"

  echo -e "${YELLOW}Updating $plugin_name...${NC}"

  # Create backup first
  local backup_path=$(backup_plugin "$plugin_name")
  if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Backup failed, skipping update${NC}"
    echo ""
    return 1
  fi

  # Download new version
  local url="https://github.com/$repo/archive/refs/heads/$branch.tar.gz"
  local temp_file="/tmp/${plugin_name}_update.tar.gz"

  echo -e "${BLUE}  Downloading from GitHub...${NC}"
  if ! curl -fSL "$url" -o "$temp_file" 2>/dev/null; then
    # Try alternate branch
    if [ "$branch" = "master" ]; then
      url="https://github.com/$repo/archive/refs/heads/main.tar.gz"
      curl -fSL "$url" -o "$temp_file" 2>/dev/null
      branch="main"
    elif [ "$branch" = "main" ]; then
      url="https://github.com/$repo/archive/refs/heads/master.tar.gz"
      curl -fSL "$url" -o "$temp_file" 2>/dev/null
      branch="master"
    fi

    if [ ! -f "$temp_file" ]; then
      echo -e "${RED}✗ Download failed${NC}"
      echo ""
      return 1
    fi
  fi

  # Extract and replace
  echo -e "${BLUE}  Installing update...${NC}"
  tar -xzf "$temp_file" -C /tmp 2>/dev/null

  # Determine extracted folder name
  local repo_name=$(basename "$repo")
  local extracted_name="${repo_name}-${branch}"

  if [ -d "/tmp/$extracted_name" ]; then
    # Remove old version
    rm -rf "$plugin_dir"

    # Move new version
    mv "/tmp/$extracted_name" "$plugin_dir"

    # Save commit info
    local commit=$(curl -s "https://api.github.com/repos/$repo/commits/$branch" | grep -m 1 '"sha"' | cut -d'"' -f4)
    if [ -n "$commit" ]; then
      echo "$commit" > "$plugin_dir/.git-commit"
    fi

    rm -f "$temp_file"
    echo -e "${GREEN}✓ Updated successfully${NC}"
    echo ""
    return 0
  else
    echo -e "${RED}✗ Extraction failed${NC}"
    echo -e "${YELLOW}  Restoring from backup...${NC}"
    restore_plugin "$backup_path" "$plugin_name"
    rm -f "$temp_file"
    echo ""
    return 1
  fi
}

# Main update logic
UPDATED=0
FAILED=0

if [ -n "$SPECIFIC_PLUGIN" ]; then
  # Update specific plugin
  if [ -z "${PLUGINS[$SPECIFIC_PLUGIN]}" ]; then
    echo -e "${RED}Error: Unknown plugin '$SPECIFIC_PLUGIN'${NC}"
    echo ""
    echo "Available plugins:"
    for plugin in "${!PLUGINS[@]}"; do
      echo "  - $plugin"
    done
    exit 1
  fi

  IFS=':' read -r repo branch <<< "${PLUGINS[$SPECIFIC_PLUGIN]}"
  update_plugin "$SPECIFIC_PLUGIN" "$repo" "$branch"
  if [ $? -eq 0 ]; then
    UPDATED=$((UPDATED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
else
  # Update all plugins
  echo -e "${BLUE}Updating all plugins...${NC}"
  echo ""

  for plugin_name in "${!PLUGINS[@]}"; do
    IFS=':' read -r repo branch <<< "${PLUGINS[$plugin_name]}"

    if [ ! -d "$PLUGIN_DIR/$plugin_name" ]; then
      echo -e "${YELLOW}⊗ $plugin_name - Not installed, skipping${NC}"
      echo ""
      continue
    fi

    update_plugin "$plugin_name" "$repo" "$branch"
    if [ $? -eq 0 ]; then
      UPDATED=$((UPDATED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  done
fi

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Update Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Successfully updated: ${GREEN}$UPDATED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""
echo -e "Backups saved to: ${BLUE}$BACKUP_DIR${NC}"
echo ""

# Clean up old backups (keep last 5)
echo -e "${BLUE}Cleaning up old backups (keeping last 5 per plugin)...${NC}"
for plugin_name in "${!PLUGINS[@]}"; do
  ls -t "$BACKUP_DIR/${plugin_name}_"*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
done

echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Restart Neovim to load updated plugins"
echo ""
