#!/bin/bash

# One-line installer for terminal setup
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/terminal-setup/main/install.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Terminal Setup Installer${NC}"

# Clone the repository
REPO_URL="${TERMINAL_SETUP_REPO:-https://github.com/YOUR_USERNAME/terminal-setup.git}"
INSTALL_DIR="$HOME/.terminal-setup"

# Remove existing installation
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Removing existing installation...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Clone repository
echo -e "${YELLOW}Cloning terminal setup...${NC}"
git clone "$REPO_URL" "$INSTALL_DIR"

# Run setup
cd "$INSTALL_DIR"
./setup.sh

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run: source ~/.zshrc${NC}"