# Machine-Specific Configurations

This directory contains machine-specific configuration overrides. This allows you to:
- Have different settings for work vs personal machines
- Override configs based on machine capabilities
- Maintain a single dotfiles repo across multiple machines

## How It Works

In your `shell/zshrc`, the following code automatically loads machine-specific configs:

```bash
# Load machine-specific configuration (if exists)
MACHINE_CONFIG="$HOME/Code/dotfiles/machines/$(hostname -s).zsh"
[[ -f "$MACHINE_CONFIG" ]] && source "$MACHINE_CONFIG"
```

## Usage

1. **Create a file** named after your machine's hostname:
   ```bash
   hostname -s  # Shows your hostname
   # Example output: MacBook-Pro

   # Create config for this machine
   touch machines/MacBook-Pro.zsh
   ```

2. **Add machine-specific settings**:
   ```bash
   # machines/MacBook-Pro.zsh

   # Work machine - use different git email
   git config --global user.email "work@company.com"

   # This machine has more RAM, increase limits
   export NODE_OPTIONS="--max-old-space-size=8192"

   # Work-specific aliases
   alias vpn="sudo openconnect vpn.company.com"
   ```

3. **Commit and sync**:
   ```bash
   git add machines/MacBook-Pro.zsh
   git commit -m "Add work machine config"
   git push
   ```

## Examples

### Work Machine

```bash
# machines/work-macbook.zsh

# Work email
git config --global user.email "you@company.com"

# Work-specific paths
export PATH="/opt/company-tools/bin:$PATH"

# Work aliases
alias deploy="ssh deploy@prod-server"
alias vpn="sudo openconnect vpn.company.com"

# Company proxy
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
```

### Personal Machine

```bash
# machines/home-macbook.zsh

# Personal email
git config --global user.email "you@personal.com"

# Personal aliases
alias blog="cd ~/Projects/blog && hugo server"
alias sync="rclone sync ~/Documents remote:backup"
```

### High-Performance Machine

```bash
# machines/mac-studio.zsh

# More aggressive performance settings
export NODE_OPTIONS="--max-old-space-size=16384"

# Use all CPU cores for builds
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"

# Docker with more resources
export DOCKER_DEFAULT_PLATFORM="linux/amd64"
```

## Tips

- Keep secrets in `~/.env.local` (never commit this!)
- Machine configs are sourced AFTER main configs, so they can override anything
- Use `hostname -s` to get the short hostname (without domain)
- You can check which config is being used:
  ```bash
  echo $MACHINE_CONFIG
  ```
