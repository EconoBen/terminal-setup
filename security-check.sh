#!/bin/bash

# Security check script - run before committing
echo "🔍 Checking for sensitive information..."

# Define patterns to search for (more specific to avoid false positives)
patterns=(
    "password=\|password:\|password "
    "secret=\|api_secret"
    "api_key=\|private_key=\|access_key="
    "token=.*[a-zA-Z0-9]"
    "192\.168\.[0-9]\+\.[0-9]\+"
    "10\.0\.[0-9]\+\.[0-9]\+"
    "sshpass -p"
)

found_issues=false

for pattern in "${patterns[@]}"; do
    echo -n "Checking for '$pattern'... "
    if grep -r -i "$pattern" configs/ --exclude="*.example" 2>/dev/null | grep -v "# Example\|# Update with your\|# Load secrets\|source ~/\.zsh_secrets\|1password\|SSH_AUTH_SOCK" > /dev/null; then
        echo "❌ FOUND"
        grep -r -i -n "$pattern" configs/ --exclude="*.example" | grep -v "# Example\|# Update with your\|# Load secrets\|source ~/\.zsh_secrets\|1password\|SSH_AUTH_SOCK"
        found_issues=true
    else
        echo "✅ Clean"
    fi
done

# Check for specific usernames or hosts that might be sensitive
echo -n "Checking for specific usernames... "
if grep -r "@[a-zA-Z0-9]\+\.[a-zA-Z0-9]\+\.[a-zA-Z0-9]\+" configs/ --exclude="*.example" | grep -v "# Example\|puppyplaza.club" > /dev/null; then
    echo "❌ FOUND"
    grep -r -n "@[a-zA-Z0-9]\+\.[a-zA-Z0-9]\+\.[a-zA-Z0-9]\+" configs/ --exclude="*.example" | grep -v "# Example\|puppyplaza.club"
    found_issues=true
else
    echo "✅ Clean"
fi

if [ "$found_issues" = true ]; then
    echo ""
    echo "⚠️  Sensitive information found! Please clean before committing."
    exit 1
else
    echo ""
    echo "✅ All checks passed! Safe to commit."
fi