#!/bin/bash

# Quick setup script for EC2 without Homebrew
# Installs essential tools using system package manager

set -e

echo "🚀 EC2 Terminal Setup (System Packages)"

# Setup passwordless sudo
if [[ "$USER" == "ubuntu" ]] || [[ "$USER" == "ec2-user" ]]; then
    echo "Setting up passwordless sudo..."
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/99-$USER-nopasswd > /dev/null
    sudo chmod 0440 /etc/sudoers.d/99-$USER-nopasswd
fi

# Update package manager
sudo apt-get update || sudo yum update -y

# Install essential tools
echo "Installing essential tools..."
if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    sudo apt-get install -y \
        zsh \
        git \
        curl \
        wget \
        build-essential \
        ripgrep \
        fd-find \
        bat \
        exa \
        fzf \
        htop \
        jq \
        tmux \
        python3-pip
    
    # Create bat symlink
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
    
    # Install starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    
elif command -v yum &> /dev/null; then
    # Amazon Linux/RHEL
    sudo yum install -y \
        zsh \
        git \
        curl \
        wget \
        gcc \
        make \
        htop \
        jq \
        tmux \
        python3-pip
    
    # Install tools not in yum
    # Ripgrep
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz
    tar xzf ripgrep-*.tar.gz
    sudo mv ripgrep-*/rg /usr/local/bin/
    rm -rf ripgrep-*
    
    # Starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Clone terminal setup
echo "Cloning terminal setup..."
git clone https://github.com/EconoBen/terminal-setup.git ~/terminal-setup
cd ~/terminal-setup

# Copy config files
echo "Installing configuration files..."
cp configs/.zshrc ~/
cp configs/.zsh_aliases ~/
cp configs/.zsh_help.md ~/
cp configs/.psqlrc ~/
mkdir -p ~/.config
cp configs/.config/starship.toml ~/.config/

# Change default shell to zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
fi

# Install Node.js and Claude Code if requested
if [[ "$1" == "--with-claude" ]]; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs || sudo yum install -y nodejs
    
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

echo "✅ Setup complete!"
echo "Please log out and back in for shell change to take effect"
echo ""
echo "Next steps:"
echo "1. Sync secrets from your local machine:"
echo "   ./sync-secrets.sh ubuntu@$(hostname -I | awk '{print $1}')"
echo "2. Run: source ~/.zshrc"