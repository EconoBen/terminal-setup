#!/bin/bash

# Quick setup script for EC2 - one command to rule them all
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/terminal-setup/main/quick-setup.sh)

set -e

echo "🚀 Quick Terminal Setup for EC2"

# Install git if not present
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
    elif command -v yum &> /dev/null; then
        sudo yum install -y git
    fi
fi

# Clone and setup
TEMP_DIR="/tmp/terminal-setup-$$"
git clone https://github.com/YOUR_USERNAME/terminal-setup.git "$TEMP_DIR"
cd "$TEMP_DIR"
./setup.sh

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Setup complete! Please run: source ~/.zshrc"