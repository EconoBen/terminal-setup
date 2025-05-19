#!/bin/bash

# Sync secrets and personal configuration to remote host
# Usage: ./sync-secrets.sh user@host

if [ -z "$1" ]; then
    echo "Usage: $0 user@host"
    echo "Example: $0 ubuntu@ec2-instance.compute.amazonaws.com"
    exit 1
fi

HOST="$1"
REMOTE_HOME="/home/ubuntu"  # Explicitly set remote home directory

echo "🔐 Syncing secrets to $HOST..."

# Files to sync (only if they exist)
FILES_TO_SYNC=(
    "$HOME/.zsh_secrets"
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_ed25519.pub"
    "$HOME/.aws/credentials"
    "$HOME/.config/gh/hosts.yml"
    "$HOME/.anthropic/claude.json"
)

# Create remote directories if needed
ssh "$HOST" "mkdir -p $REMOTE_HOME/.ssh $REMOTE_HOME/.config/gh $REMOTE_HOME/.aws $REMOTE_HOME/.anthropic"

# Sync each file if it exists
for file in "${FILES_TO_SYNC[@]}"; do
    if [ -f "$file" ]; then
        echo "Copying $(basename $file)..."
        # Replace home directory with remote home
        remote_file="${file/#$HOME/$REMOTE_HOME}"
        scp "$file" "$HOST:$remote_file"
    else
        echo "Skipping $(basename $file) (not found locally)"
    fi
done

# Fix permissions on remote
ssh "$HOST" << 'EOF'
chmod 600 ~/.ssh/id_* 2>/dev/null || true
chmod 600 ~/.aws/credentials 2>/dev/null || true
chmod 600 ~/.anthropic/claude.json 2>/dev/null || true
EOF

echo "✅ Sync complete!"
echo ""
echo "Next steps on $HOST:"
echo "1. cd terminal-setup && ./setup.sh --with-claude"
echo "2. source ~/.zshrc"
echo "3. Test secrets: echo \$GITHUB_TOKEN | cut -c1-10"
echo "4. Test Claude Code: claude --version"