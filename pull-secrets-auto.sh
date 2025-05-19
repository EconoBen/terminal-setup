#!/bin/bash

# Auto pull secrets using configuration file
# Usage: Just run ./pull-secrets-auto.sh (no arguments needed)

# Load configuration
CONFIG_FILE="$HOME/.terminal-setup.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found at $CONFIG_FILE"
    echo "Please run the terminal setup first!"
    exit 1
fi

# Source the config
source "$CONFIG_FILE"

# Build the connection string
LOCAL_CONNECTION="${LOCAL_USER}@${LOCAL_HOST}"

echo "🔐 Pulling secrets from $LOCAL_CONNECTION..."
echo "(Loaded from $CONFIG_FILE)"

# Files to pull
FILES_TO_SYNC=(
    ".zsh_secrets"
    ".ssh/id_ed25519"
    ".ssh/id_ed25519.pub"
    ".aws/credentials"
    ".config/gh/hosts.yml"
    ".anthropic/claude.json"
)

# Create local directories if needed
mkdir -p ~/.ssh ~/.config/gh ~/.aws ~/.anthropic

# Pull each file if it exists on local
for file in "${FILES_TO_SYNC[@]}"; do
    echo -n "Pulling $file... "
    # Try to copy from local to remote
    if scp "$LOCAL_CONNECTION:~/$file" "~/$file" 2>/dev/null; then
        echo "✓"
    else
        echo "✗ (not found)"
    fi
done

# Fix permissions
chmod 600 ~/.ssh/id_* 2>/dev/null || true
chmod 600 ~/.aws/credentials 2>/dev/null || true
chmod 600 ~/.anthropic/claude.json 2>/dev/null || true

echo ""
echo "✅ Pull complete!"
echo ""
echo "Test your setup:"
echo "  • source ~/.zshrc"
echo "  • echo \$GITHUB_TOKEN | cut -c1-10"
echo "  • claude --version"