#!/bin/bash

# Universal Terminal Setup Script
# Works on macOS, Ubuntu/Debian, RHEL/Amazon Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Universal Terminal Setup${NC}"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
elif [[ -f /etc/redhat-release ]]; then
    OS="redhat"
else
    echo -e "${RED}Unsupported OS${NC}"
    exit 1
fi

echo -e "${YELLOW}Detected OS: $OS${NC}"

# Setup passwordless sudo for EC2
setup_sudo() {
    if [[ "$USER" == "ubuntu" ]] || [[ "$USER" == "ec2-user" ]]; then
        echo -e "${YELLOW}Setting up passwordless sudo for EC2...${NC}"
        echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
        echo -e "${GREEN}Passwordless sudo enabled${NC}"
    fi
}

# Install package manager
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ "$OS" == "macos" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

# Install system dependencies
install_system_deps() {
    case $OS in
        debian)
            sudo apt-get update
            sudo apt-get install -y build-essential curl git zsh wget
            ;;
        redhat)
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y curl git zsh wget
            ;;
        macos)
            # Xcode tools usually already installed
            xcode-select --install 2>/dev/null || true
            ;;
    esac
}

# Install tools via Homebrew
install_tools() {
    echo -e "${YELLOW}Installing tools via Homebrew...${NC}"
    
    # Core tools available on all platforms
    brew install eza ripgrep fzf bat fd starship glow
    
    # Platform-specific handling
    if [[ "$OS" == "macos" ]]; then
        brew bundle --file="$SCRIPT_DIR/Brewfile"
    else
        # Linux-specific - skip casks and some macOS-only tools
        brew install btop duf lazygit pgcli pspg pgformatter duckdb || true
        brew install --build-from-source bandwhich || true
    fi
    
    # Install FZF key bindings
    $(brew --prefix)/opt/fzf/install --all --no-update-rc
}

# Copy configuration files
copy_configs() {
    echo -e "${YELLOW}Copying configuration files...${NC}"
    
    # Create directories
    mkdir -p ~/.config
    
    # Copy files from configs directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    CONFIG_DIR="$SCRIPT_DIR/configs"
    
    # Copy all config files
    cp "$CONFIG_DIR/.zshrc" ~/
    cp "$CONFIG_DIR/.zsh_aliases" ~/
    cp "$CONFIG_DIR/.zsh_help.md" ~/
    cp "$CONFIG_DIR/.psqlrc" ~/
    cp "$CONFIG_DIR/.config/starship.toml" ~/.config/
}

# Platform-specific adjustments
platform_adjustments() {
    if [[ "$OS" != "macos" ]]; then
        # Linux-specific adjustments
        sed -i 's/alias netscan=.*/# alias netscan - macOS only/' ~/.zsh_aliases 2>/dev/null || true
        
        # Add Linux-specific aliases
        echo "" >> ~/.zsh_aliases
        echo "# Linux-specific aliases" >> ~/.zsh_aliases
        echo "alias open='xdg-open'" >> ~/.zsh_aliases
    fi
}

# Change default shell to zsh
set_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo -e "${YELLOW}Changing default shell to zsh...${NC}"
        chsh -s $(which zsh)
    fi
}

# Install Claude Code
install_claude_code() {
    echo -e "${YELLOW}Installing Claude Code...${NC}"
    
    # First ensure Node.js is installed
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}Installing Node.js...${NC}"
        if [[ "$OS" == "macos" ]]; then
            brew install node
        else
            # Install Node.js via NodeSource for Linux
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
    fi
    
    # Install Claude Code globally
    echo -e "${YELLOW}Installing Claude Code via npm...${NC}"
    npm install -g @anthropic-ai/claude-code
    
    echo -e "${GREEN}Claude Code installed${NC}"
    echo "Run 'claude' to start using Claude Code"
}

# Main execution
main() {
    setup_sudo
    install_system_deps
    install_homebrew
    install_tools
    copy_configs
    platform_adjustments
    set_default_shell
    
    # Optional: Install Claude Code
    if [[ "$1" == "--with-claude" ]]; then
        install_claude_code
    fi
    
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${YELLOW}Please restart your terminal or run: source ~/.zshrc${NC}"
    
    # Provide sync command if on EC2
    if [[ "$USER" == "ubuntu" ]] || [[ "$USER" == "ec2-user" ]]; then
        echo -e "\n${YELLOW}To sync secrets from your local machine:${NC}"
        echo "scp ~/.zsh_secrets ubuntu@\$(hostname -I | awk '{print \$1}'):~/"
    fi
}

main "$@"