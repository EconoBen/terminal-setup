# Zsh Configuration
# Plugin loading order is important - syntax highlighting needs to be near the end

# Enable mouse support for cursor positioning
if [[ $TERM == "xterm"* ]]; then
    export TERM="xterm-256color"
fi

# History Configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from history
setopt HIST_VERIFY               # Show command with history expansion before running it
setopt SHARE_HISTORY             # Share history between all sessions
setopt EXTENDED_HISTORY          # Record timestamp of command

# Directory Navigation
setopt AUTO_CD                   # Type directory name to cd into it
setopt AUTO_PUSHD               # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS        # Don't push multiple copies of same directory
setopt PUSHD_MINUS              # Exchanges meanings of + and - when used with cd
DIRSTACKSIZE=8                  # Limit directory stack size

# Completion Improvements
setopt MENU_COMPLETE            # Cycle through completions with tab
setopt AUTO_LIST                # List choices on ambiguous completion
setopt COMPLETE_IN_WORD         # Complete from both ends of word
setopt ALWAYS_TO_END            # Move cursor to end after completion

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Colored completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Base PATH (setting this first, then adding to it)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# PATH organization - group by category
# Homebrew paths
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/bzip2/bin:$PATH"

# User local paths (only add once)
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Development tools
export PATH="/usr/local/opt/llvm/bin:$PATH"

# Cloud tools
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# Cargo Environment Initialization
. "$HOME/.cargo/env"

# Java Configuration (fixed order)
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"

# Remove duplicates from PATH
typeset -U PATH path

# Load secrets file (GitHub tokens, API keys, etc.)
if [ -f ~/.zsh_secrets ]; then
    source ~/.zsh_secrets
fi

# Starship Prompt Initialization
eval "$(starship init zsh)"

# RUFF
fpath+=~/.zfunc
autoload -Uz compinit && compinit

# CURSOR
function cursor {
  open -a "/Applications/Cursor.app" "$@"
}

# NVM (Node Version Manager) Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load NVM bash_completion

# Additional Environment Variables
export HDF5_DIR="/opt/homebrew/Cellar/hdf5/1.14.1"
export LZO_DIR="/opt/homebrew/opt/lzo"
export BZIP2_DIR="/opt/homebrew/opt/bzip2"
export BLOSC_DIR="/opt/homebrew/opt/c-blosc"
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export GPG_TTY=$(tty)

# Google Cloud SDK Configuration
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# Google Cloud SDK Command Completion
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

## Source zsh aliases (moved to end after PATH is fully set up)
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi


## Source zsh improvements
if [ -f ~/.zsh_improvements ]; then
    source ~/.zsh_improvements
fi

# Zsh Plugin Integration (Order matters!)
# Auto-suggestions first
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Load zsh-autocomplete
source /opt/homebrew/Cellar/zsh-autocomplete/24.09.04/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Syntax Highlighting (must be loaded last)
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    # Suppress warning for known widget compatibility issues
    typeset -g ZSH_HIGHLIGHT_MAXLENGTH=512
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# FZF Integration
if command -v fzf &> /dev/null; then
    # Set up fzf key bindings and fuzzy completion
    eval "$(fzf --zsh)"
fi

# AWS CLI Completion
autoload -U +X bashcompinit && bashcompinit
complete -C '/opt/homebrew/bin/aws_completer' aws

# AWS Vault completion (if installed)
if command -v aws-vault &> /dev/null; then
    eval "$(aws-vault --completion-script-zsh)"
fi


