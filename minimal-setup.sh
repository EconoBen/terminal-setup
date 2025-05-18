#!/bin/bash

# Minimal setup for resource-constrained environments
# Just the essentials without heavy dependencies

set -e

echo "Minimal Terminal Setup"

# Install just the essentials
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y zsh git curl
elif command -v yum &> /dev/null; then
    sudo yum update -y
    sudo yum install -y zsh git curl
fi

# Copy basic configs
mkdir -p ~/.config

# Create minimal .zshrc
cat > ~/.zshrc << 'EOF'
# Minimal zshrc
export PATH="$PATH:$HOME/.local/bin"

# Basic aliases
alias ll='ls -la'
alias ..='cd ..'
alias ...='cd ../..'

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Basic prompt (no starship)
PROMPT='%n@%m %~ %# '

# Source aliases if exists
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
EOF

# Copy aliases (removing tool-specific ones)
if [[ -f ~/.zsh_aliases ]]; then
    grep -v "eza\|bat\|btop\|ripgrep\|fzf" ~/.zsh_aliases > ~/.zsh_aliases.minimal
    mv ~/.zsh_aliases.minimal ~/.zsh_aliases
fi

# Change shell
chsh -s $(which zsh)

echo "Minimal setup complete!"