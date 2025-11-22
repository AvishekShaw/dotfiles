#!/bin/bash
# ============================================================================
# Install Neovim Plugins with Curl (No Git Required)
# ============================================================================
# This script downloads all plugins from init.lua using only curl
# Use this on systems without git/Xcode Command Line Tools

# Don't exit on error - we want to install as many plugins as possible
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Plugin directory
PLUGIN_DIR="$HOME/.local/share/nvim/site/pack/plugins/start"
LAZY_DIR="$HOME/.local/share/nvim/lazy"

# Track success/failure
TOTAL_PLUGINS=0
SUCCESSFUL_PLUGINS=0
FAILED_PLUGINS=()

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Neovim Plugin Installer (curl-only)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create directories
mkdir -p "$PLUGIN_DIR"
mkdir -p "$LAZY_DIR"

# Function to install a plugin
install_plugin() {
  local repo=$1
  local branch=${2:-master}
  local name=$(basename "$repo")
  local target_dir="$3"

  if [ -z "$target_dir" ]; then
    target_dir="$PLUGIN_DIR/$name"
  fi

  echo -e "${YELLOW}Installing $name...${NC}"
  TOTAL_PLUGINS=$((TOTAL_PLUGINS + 1))

  # Try master branch first
  local url="https://github.com/$repo/archive/refs/heads/$branch.tar.gz"
  local temp_file="/tmp/$name.tar.gz"

  if curl -fSL "$url" -o "$temp_file" 2>/dev/null; then
    tar -xzf "$temp_file" -C /tmp

    # Move extracted folder to target
    local extracted_name="${name}-${branch}"
    if [ -d "/tmp/$extracted_name" ]; then
      rm -rf "$target_dir"
      mv "/tmp/$extracted_name" "$target_dir"
      rm -f "$temp_file"
      echo -e "${GREEN}✓ Installed $name${NC}"
      SUCCESSFUL_PLUGINS=$((SUCCESSFUL_PLUGINS + 1))
      return 0
    fi
  fi

  # Try main branch if master failed
  if [ "$branch" = "master" ]; then
    echo -e "${YELLOW}  Trying 'main' branch...${NC}"
    url="https://github.com/$repo/archive/refs/heads/main.tar.gz"
    if curl -fSL "$url" -o "$temp_file" 2>/dev/null; then
      tar -xzf "$temp_file" -C /tmp
      local extracted_name="${name}-main"
      if [ -d "/tmp/$extracted_name" ]; then
        rm -rf "$target_dir"
        mv "/tmp/$extracted_name" "$target_dir"
        rm -f "$temp_file"
        echo -e "${GREEN}✓ Installed $name${NC}"
        SUCCESSFUL_PLUGINS=$((SUCCESSFUL_PLUGINS + 1))
        return 0
      fi
    fi
  fi

  echo -e "${RED}✗ Failed to install $name${NC}"
  FAILED_PLUGINS+=("$name")
  rm -f "$temp_file"
  return 1
}

# Function to install a plugin by tag
install_plugin_by_tag() {
  local repo=$1
  local tag=$2
  local name=$(basename "$repo")
  local target_dir="$3"

  if [ -z "$target_dir" ]; then
    target_dir="$PLUGIN_DIR/$name"
  fi

  echo -e "${YELLOW}Installing $name @ $tag...${NC}"
  TOTAL_PLUGINS=$((TOTAL_PLUGINS + 1))

  local url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"
  local temp_file="/tmp/$name.tar.gz"

  if curl -fSL "$url" -o "$temp_file" 2>/dev/null; then
    tar -xzf "$temp_file" -C /tmp

    # Extract folder name (tag might have 'v' prefix)
    local extracted_name="${name}-${tag#v}"
    if [ ! -d "/tmp/$extracted_name" ]; then
      extracted_name="${name}-${tag}"
    fi

    if [ -d "/tmp/$extracted_name" ]; then
      rm -rf "$target_dir"
      mv "/tmp/$extracted_name" "$target_dir"
      rm -f "$temp_file"
      echo -e "${GREEN}✓ Installed $name @ $tag${NC}"
      SUCCESSFUL_PLUGINS=$((SUCCESSFUL_PLUGINS + 1))
      return 0
    fi
  fi

  echo -e "${RED}✗ Failed to install $name @ $tag${NC}"
  FAILED_PLUGINS+=("$name")
  rm -f "$temp_file"
  return 1
}

# Function to install a plugin by commit
install_plugin_by_commit() {
  local repo=$1
  local commit=$2
  local name=$(basename "$repo")
  local target_dir="$3"

  if [ -z "$target_dir" ]; then
    target_dir="$PLUGIN_DIR/$name"
  fi

  echo -e "${YELLOW}Installing $name @ ${commit:0:7}...${NC}"
  TOTAL_PLUGINS=$((TOTAL_PLUGINS + 1))

  local url="https://github.com/$repo/archive/$commit.tar.gz"
  local temp_file="/tmp/$name.tar.gz"

  if curl -fSL "$url" -o "$temp_file" 2>/dev/null; then
    tar -xzf "$temp_file" -C /tmp

    local extracted_name="${name}-${commit}"

    if [ -d "/tmp/$extracted_name" ]; then
      rm -rf "$target_dir"
      mv "/tmp/$extracted_name" "$target_dir"
      rm -f "$temp_file"
      echo -e "${GREEN}✓ Installed $name @ ${commit:0:7}${NC}"
      SUCCESSFUL_PLUGINS=$((SUCCESSFUL_PLUGINS + 1))
      return 0
    fi
  fi

  echo -e "${RED}✗ Failed to install $name @ ${commit:0:7}${NC}"
  FAILED_PLUGINS+=("$name")
  rm -f "$temp_file"
  return 1
}

echo -e "${GREEN}Installing lazy.nvim (plugin manager)...${NC}"
install_plugin "folke/lazy.nvim" "stable" "$LAZY_DIR/lazy.nvim"

echo ""
echo -e "${GREEN}Installing plugins...${NC}"
echo ""

# Core dependencies
install_plugin "nvim-lua/plenary.nvim"
install_plugin "nvim-tree/nvim-web-devicons"

# Colorscheme
install_plugin "catppuccin/nvim" "main" "$PLUGIN_DIR/catppuccin"

# File Explorer
install_plugin "nvim-tree/nvim-tree.lua"

# Completion engine
install_plugin_by_commit "hrsh7th/nvim-cmp" "ae644feb7b67bf1ce4260c231d1d4300b19c6f30"
install_plugin "hrsh7th/cmp-nvim-lsp"
install_plugin "hrsh7th/cmp-buffer"
install_plugin "hrsh7th/cmp-path"
install_plugin "L3MON4D3/LuaSnip"
install_plugin "saadparwaiz1/cmp_luasnip"
install_plugin "rafamadriz/friendly-snippets"

# Obsidian (note-taking)
install_plugin "epwalsh/obsidian.nvim"

# Fuzzy finder
install_plugin_by_tag "nvim-telescope/telescope.nvim" "0.1.8"

# Syntax highlighting (treesitter)
install_plugin "nvim-treesitter/nvim-treesitter"

# Git integration
install_plugin "lewis6991/gitsigns.nvim"

# Markdown rendering
install_plugin "MeanderingProgrammer/render-markdown.nvim"

# Jupyter/Notebook support
install_plugin "benlubas/molten-nvim"
install_plugin_by_commit "GCBallesteros/NotebookNavigator.nvim" "20cb6f72939194e32eb3060578b445e5f2e7ae8b"
install_plugin "GCBallesteros/jupytext.nvim"

# Image support
install_plugin "3rd/image.nvim"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Successfully installed: $SUCCESSFUL_PLUGINS/$TOTAL_PLUGINS plugins${NC}"

if [ ${#FAILED_PLUGINS[@]} -gt 0 ]; then
  echo -e "${RED}Failed plugins (${#FAILED_PLUGINS[@]}):${NC}"
  for plugin in "${FAILED_PLUGINS[@]}"; do
    echo -e "  ${RED}✗${NC} $plugin"
  done
  echo ""
  echo -e "${YELLOW}Note:${NC} Failed plugins may still work if lazy.nvim can download them using git"
  echo ""
fi

echo -e "Plugins installed to: ${YELLOW}$PLUGIN_DIR${NC}"
echo -e "Lazy.nvim installed to: ${YELLOW}$LAZY_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Copy your init.lua to ~/.config/nvim/init.lua"
echo "2. Open Neovim: nvim"
echo "3. Run :checkhealth to verify installation"
echo ""
echo -e "${YELLOW}Note:${NC} Some plugins may need additional setup:"
echo "- Treesitter parsers: Run :TSInstall <language> in Neovim"
echo "- Molten: Requires Python and Jupyter (pip install jupyter)"
echo "- Image.nvim: Requires Kitty terminal"
echo ""
