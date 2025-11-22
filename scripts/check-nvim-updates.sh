#!/bin/bash
# ============================================================================
# Check for Neovim Plugin Updates (curl-only)
# ============================================================================
# Checks GitHub for newer versions of installed plugins

set +e  # Don't exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGIN_DIR="$HOME/.local/share/nvim/lazy"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Neovim Plugin Update Checker${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ ! -d "$PLUGIN_DIR" ]; then
  echo -e "${RED}Error: Plugin directory not found: $PLUGIN_DIR${NC}"
  exit 1
fi

# Function to get local commit hash from a plugin
get_local_commit() {
  local plugin_dir=$1
  local commit_file="$plugin_dir/.git-commit"

  if [ -f "$commit_file" ]; then
    cat "$commit_file"
  else
    echo "unknown"
  fi
}

# Function to get remote latest commit
get_remote_commit() {
  local repo=$1
  local branch=${2:-master}

  # Try master first
  local commit=$(curl -s "https://api.github.com/repos/$repo/commits/$branch" | grep -m 1 '"sha"' | cut -d'"' -f4)

  # If master failed, try main
  if [ -z "$commit" ]; then
    commit=$(curl -s "https://api.github.com/repos/$repo/commits/main" | grep -m 1 '"sha"' | cut -d'"' -f4)
  fi

  echo "$commit"
}

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

echo -e "${BLUE}Checking for updates...${NC}"
echo ""

UPDATES_AVAILABLE=0
UPDATES_LIST=()

for plugin_name in "${!PLUGINS[@]}"; do
  plugin_dir="$PLUGIN_DIR/$plugin_name"

  if [ ! -d "$plugin_dir" ]; then
    echo -e "${YELLOW}⊗ $plugin_name${NC} - Not installed"
    continue
  fi

  # Parse repo and branch
  IFS=':' read -r repo branch <<< "${PLUGINS[$plugin_name]}"

  local_commit=$(get_local_commit "$plugin_dir")

  echo -ne "Checking ${BLUE}$plugin_name${NC}... "

  remote_commit=$(get_remote_commit "$repo" "$branch")

  if [ -z "$remote_commit" ]; then
    echo -e "${RED}Failed to fetch remote${NC}"
    continue
  fi

  # Compare commits (first 7 chars)
  local_short="${local_commit:0:7}"
  remote_short="${remote_commit:0:7}"

  if [ "$local_commit" = "unknown" ]; then
    echo -e "${YELLOW}Unknown version${NC} (remote: $remote_short)"
  elif [ "$local_short" = "$remote_short" ]; then
    echo -e "${GREEN}✓ Up to date${NC} ($local_short)"
  else
    echo -e "${YELLOW}⚠ Update available${NC} (local: $local_short → remote: $remote_short)"
    UPDATES_AVAILABLE=$((UPDATES_AVAILABLE + 1))
    UPDATES_LIST+=("$plugin_name:$repo:$branch")
  fi
done

echo ""
echo -e "${GREEN}========================================${NC}"

if [ $UPDATES_AVAILABLE -eq 0 ]; then
  echo -e "${GREEN}All plugins are up to date!${NC}"
else
  echo -e "${YELLOW}$UPDATES_AVAILABLE update(s) available${NC}"
  echo ""
  echo -e "${BLUE}To update plugins, run:${NC}"
  echo -e "  ${YELLOW}./update-nvim-plugins.sh${NC}"
  echo ""
  echo -e "${BLUE}To update specific plugins:${NC}"
  for item in "${UPDATES_LIST[@]}"; do
    IFS=':' read -r name repo branch <<< "$item"
    echo -e "  ${YELLOW}./update-nvim-plugins.sh $name${NC}"
  done
fi

echo -e "${GREEN}========================================${NC}"
echo ""
