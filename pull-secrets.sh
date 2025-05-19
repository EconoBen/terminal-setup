#!/bin/bash

# Pull secrets from local machine while on EC2
# Usage: Run this ON your EC2 instance: ./pull-secrets.sh user@local-machine

if [ -z "$1" ]; then
    echo "Usage: $0 user@local-machine"
    echo "Example: $0 myuser@my-macbook.local"
    echo "Run this ON your EC2 instance to pull secrets FROM your local machine"
    exit 1
fi

LOCAL_HOST="$1"

echo "🔐 Pulling secrets from $LOCAL_HOST..."

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
    echo "Pulling $file..."
    # Try to copy from local to remote
    if scp "$LOCAL_HOST:~/$file" "~/$file" 2>/dev/null; then
        echo "✓ Pulled $file"
    else
        echo "✗ Skipping $file (not found on local)"
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