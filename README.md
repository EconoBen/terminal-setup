# Terminal Setup

🚀 **One-command terminal setup for macOS and Linux systems**

## Quick Start

### On EC2 / Linux:
```bash
# Option 1: Quick setup (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/EconoBen/terminal-setup/main/quick-setup.sh)

# Option 2: Clone and install
git clone https://github.com/EconoBen/terminal-setup.git ~/.terminal-setup
cd ~/.terminal-setup && ./setup.sh
```

### On macOS:
```bash
git clone https://github.com/EconoBen/terminal-setup.git ~/.terminal-setup
cd ~/.terminal-setup && ./setup.sh
```

## Overview
Standardized terminal configuration that works across:
- macOS (local development)
- EC2 instances (Amazon Linux, Ubuntu)
- Other Linux systems

## Repository Structure

```
terminal-setup/
├── configs/              # All configuration files
│   ├── .zshrc           # Shell configuration
│   ├── .zsh_aliases     # Command aliases  
│   ├── .zsh_help.md     # Help documentation
│   ├── .psqlrc          # PostgreSQL config
│   ├── .zsh_personal.example # Personal config template
│   └── .config/
│       └── starship.toml # Prompt configuration
├── Brewfile             # Package list
├── setup.sh             # Main setup script
├── quick-setup.sh       # One-line installer
├── minimal-setup.sh     # Lightweight option
└── README.md            # This file
```

### Scripts
- `setup.sh` - Universal setup script (works on macOS/Linux)
- `sync-to-ec2.sh` - Sync and setup on EC2 instances
- `minimal-setup.sh` - Lightweight setup for constrained environments

## Installation Methods

### 1. Quick Install (Recommended for EC2)
```bash
# Basic installation
bash <(curl -fsSL https://raw.githubusercontent.com/EconoBen/terminal-setup/main/quick-setup.sh)

# With Claude Code
bash <(curl -fsSL https://raw.githubusercontent.com/EconoBen/terminal-setup/main/quick-setup.sh) --with-claude
```

### 2. Standard Install
```bash
git clone https://github.com/EconoBen/terminal-setup.git ~/.terminal-setup
cd ~/.terminal-setup
./setup.sh
```

### 3. Minimal Install (Resource-constrained)
```bash
git clone https://github.com/EconoBen/terminal-setup.git ~/.terminal-setup
cd ~/.terminal-setup
./minimal-setup.sh
```

### 4. Sync Secrets from Local
After installation, sync your sensitive files:
```bash
# From your local machine
cd ~/Documents/GitHub/terminal-setup
./sync-secrets.sh ubuntu@your-ec2-instance
```

## Platform Differences

### macOS
- Full Brewfile support
- Cask applications (fonts, GUI apps)
- Network scanning tools

### Linux
- Homebrew on Linux (linuxbrew)
- Some tools installed from source
- Platform-specific adjustments applied

### Amazon Linux / EC2
- Handles both yum and apt
- Skips macOS-specific tools
- Optimized for cloud environments

## Making Changes

### Update Configuration
1. Edit files in `configs/` directory
2. Commit and push to GitHub
3. Run setup again on target systems

### Add New Tools
1. Add to `Brewfile`
2. Update `setup.sh` if platform-specific
3. Document in `configs/.zsh_help.md`
4. Commit and push

### Fork for Personal Use
1. Fork this repository
2. Update `quick-setup.sh` with your GitHub username
3. Customize configurations
4. Use your fork's URL for installation

## Troubleshooting

### Homebrew on Linux
If Homebrew fails, the script falls back to system package managers.

### Fonts on Linux
Nerd Fonts must be installed manually on Linux systems.

### SSH Key Setup
Remember to set up SSH keys before syncing:
```bash
ssh-copy-id user@ec2-instance
```
