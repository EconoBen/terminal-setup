#!/bin/bash

# Sync terminal setup to EC2 instance
# Usage: ./sync-to-ec2.sh user@ec2-instance

if [ -z "$1" ]; then
    echo "Usage: $0 user@ec2-instance"
    exit 1
fi

EC2_HOST="$1"
SETUP_DIR="$HOME/.config/terminal-setup"

echo "Syncing terminal setup to $EC2_HOST..."

# Create setup directory on remote
ssh "$EC2_HOST" "mkdir -p ~/.config/terminal-setup"

# Copy all config files
rsync -av --progress \
    ~/.zshrc \
    ~/.zsh_aliases \
    ~/.zsh_help.md \
    ~/.psqlrc \
    ~/.config/starship.toml \
    "$SETUP_DIR/" \
    "$EC2_HOST:~/.config/terminal-setup/"

# Copy setup script and make executable
scp "$SETUP_DIR/setup.sh" "$EC2_HOST:~/.config/terminal-setup/"
ssh "$EC2_HOST" "chmod +x ~/.config/terminal-setup/setup.sh"

# Run setup on remote
ssh -t "$EC2_HOST" "cd ~/.config/terminal-setup && ./setup.sh"

echo "Setup complete! Reconnect with: ssh $EC2_HOST"