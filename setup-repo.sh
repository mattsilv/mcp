#!/bin/bash

# Initialize git repository with best practices for MCP server setup

echo "Initializing MCP Servers repository..."

# Initialize git repository if not already done
if [ ! -d .git ]; then
  git init
  echo "Git repository initialized"
else
  echo "Git repository already exists"
fi

# Add gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
  cat > .gitignore << EOL
# Virtual environments
.venv/
venv/
env/
.env

# Database files
*.db
*.sqlite
*.sqlite3
test.db

# Secrets and credentials
.claude_env
*_token*
*.key
*.pem

# OS specific files
.DS_Store
Thumbs.db

# Python cache
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/

# Node modules
node_modules/

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
log/
logs/

# Build directories
dist/
build/
*.egg-info/

# Docker related
.docker/

# Production config files
claude_desktop_config.json
claude_desktop_config.original.json
claude_desktop_config.prod.json
EOL
  echo "Created .gitignore file"
else
  echo ".gitignore file already exists"
fi

# Ensure template config exists
if [ ! -f claude_desktop_config.template.json ]; then
  echo "Error: Template configuration file not found."
  echo "Please create claude_desktop_config.template.json first."
  exit 1
fi

# Create a README if it doesn't exist
if [ ! -f README.md ]; then
  echo "# MCP Servers" > README.md
  echo "" >> README.md
  echo "Configuration and setup for various Model Context Protocol (MCP) servers to use with Claude Desktop and other AI assistants." >> README.md
  echo "Created basic README.md"
else
  echo "README.md already exists"
fi

# Stage files
git add README.md .gitignore claude_desktop_config.template.json setup-mcp-secrets.sh install-config.sh uv_notes.md setup-repo.sh

# Check if we need to make an initial commit
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit -m "Initial commit: MCP Servers configuration setup"
  echo "Created initial commit"
else
  echo "Repository already has commits"
fi

echo "Repository setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy claude_desktop_config.template.json to a new file and customize with your paths"
echo "2. Run ./install-config.sh to install your customized configuration"
echo "3. Run ./setup-mcp-secrets.sh to configure any necessary secrets"
echo "4. Restart Claude Desktop to apply changes" 