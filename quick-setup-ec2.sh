#!/bin/bash

# Quick setup script for EC2 without Homebrew
# Installs essential tools using system package manager

set -e

echo "🚀 EC2 Terminal Setup (System Packages)"

# Setup passwordless sudo
if [[ "$USER" == "ubuntu" ]] || [[ "$USER" == "ec2-user" ]]; then
    echo "Setting up passwordless sudo..."
    # Create proper sudoers file
    echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
    # Make sure it has correct permissions
    sudo chmod 440 /etc/sudoers.d/$USER
    # Reload sudo to pick up changes
    sudo -k
    # Export DEBIAN_FRONTEND to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
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
    
    # Install starship - force yes and non-interactive
    export FORCE=1
    echo "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sudo -E sh -s -- -y >/dev/null 2>&1
    echo "✓ Starship installed"
    
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
    
    # Starship - force yes and non-interactive
    export FORCE=1
    echo "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sudo -E sh -s -- -y >/dev/null 2>&1
    echo "✓ Starship installed"
fi

# Clone or update terminal setup
echo "Setting up terminal configuration..."
if [ -d ~/terminal-setup ]; then
    echo "Updating existing terminal setup..."
    cd ~/terminal-setup
    git fetch origin
    git reset --hard origin/main
else
    echo "Cloning terminal setup..."
    git clone https://github.com/EconoBen/terminal-setup.git ~/terminal-setup
    cd ~/terminal-setup
fi

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

# Always install Node.js and Claude Code
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs || sudo yum install -y nodejs

echo "Installing Claude Code..."
sudo npm install -g @anthropic-ai/claude-code

# Create Claude configuration directory
mkdir -p ~/.anthropic

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎉 Installed:"
echo "  • Zsh shell with custom configuration"
echo "  • Starship prompt"
echo "  • CLI tools: ripgrep, bat, exa, fzf, etc."
echo "  • Claude Code (AI coding assistant)"
echo "  • Node.js and npm"
echo ""
echo "📋 Next steps:"
echo "1. Switch to zsh: exec zsh"
echo "2. From your local machine, sync secrets:"
echo "   cd ~/Documents/GitHub/terminal-setup"
echo "   ./sync-secrets.sh ubuntu@$(curl -s ifconfig.me)"
echo "3. Test Claude: claude --version"