#!/bin/bash

# Setup script for MCP secrets in Claude Desktop
# This script automates the process of creating and loading environment variables
# for use with Claude Desktop MCP servers

echo "🔐 Setting up MCP secrets for Claude Desktop..."

# Create a .claude_env file if it doesn't exist
if [ ! -f ~/.claude_env ]; then
  touch ~/.claude_env
  chmod 600 ~/.claude_env
  echo "✅ Created ~/.claude_env file"
else
  echo "ℹ️ ~/.claude_env file already exists"
fi

# Prompt for GitHub token if not already set
if ! grep -q "CLAUDE_DESKTOP_GITHUB_TOKEN" ~/.claude_env; then
  read -p "Enter your GitHub Personal Access Token: " github_token
  echo "CLAUDE_DESKTOP_GITHUB_TOKEN=$github_token" >> ~/.claude_env
  echo "✅ Added GitHub token to ~/.claude_env"
else
  echo "ℹ️ GitHub token already exists in ~/.claude_env"
fi

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
  SHELL_PROFILE=~/.zshrc
  echo "ℹ️ Detected ZSH shell"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_PROFILE=~/.bashrc
  echo "ℹ️ Detected Bash shell"
else
  # Default to zsh on macOS
  SHELL_PROFILE=~/.zshrc
  echo "ℹ️ Using default ZSH profile"
fi

# Add loading code to shell profile if not already there
if ! grep -q "claude_env" "$SHELL_PROFILE"; then
  echo '
# Claude Desktop environment variables
if [ -f ~/.claude_env ]; then
  export $(grep -v "^#" ~/.claude_env | xargs)
fi' >> "$SHELL_PROFILE"
  echo "✅ Added environment loading code to $SHELL_PROFILE"
else
  echo "ℹ️ Environment loading code already exists in $SHELL_PROFILE"
fi

# Source the environment file
source ~/.claude_env
echo "ℹ️ Loaded environment from ~/.claude_env"

# Source the shell profile (warning: this can have side effects)
echo "ℹ️ To load your updated profile, run: source $SHELL_PROFILE"

# Verify token is loaded
if [ -n "$CLAUDE_DESKTOP_GITHUB_TOKEN" ]; then
  echo "✅ GitHub token successfully loaded: ${CLAUDE_DESKTOP_GITHUB_TOKEN:0:5}..."
  
  # Test GitHub API access
  echo "🔍 Testing GitHub API access..."
  user=$(curl -s -H "Authorization: token $CLAUDE_DESKTOP_GITHUB_TOKEN" https://api.github.com/user)
  if echo "$user" | grep -q "login"; then
    login=$(echo "$user" | grep "login" | cut -d'"' -f4)
    echo "✅ GitHub API access successful! Connected as: $login"
  else
    echo "❌ GitHub API access failed. Please check your token."
    echo "Response: $user"
  fi
else
  echo "❌ GitHub token not loaded. Please check your setup."
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo "1. Run: source $SHELL_PROFILE"
echo "2. Restart Claude Desktop"
echo "3. Test the GitHub functionality"
echo ""
echo "If you encounter any issues, see the Troubleshooting section in the README.md" 