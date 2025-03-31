# Working with UV in MCP Projects

This document provides guidelines on how to work with `uv` for Python package management in MCP server projects.

## Installation of MCP Servers

### Python-based MCP Servers

For Python-based MCP servers, always use `uv tool install` instead of pip:

```bash
# Install MCP servers as tools
uv tool install mcp-server-time
uv tool install mcp-server-fetch
```

This makes them available globally as commands and is the recommended approach for MCP servers.

### Node.js-based MCP Servers

For Node.js-based MCP servers, use npm to install them globally:

```bash
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github
```

### Docker-based MCP Servers

For Docker-based MCP servers like SQLite and Puppeteer, build the Docker images:

```bash
# For SQLite
docker build -t mcp/sqlite /path/to/sqlite

# For Puppeteer
docker build -t mcp/puppeteer /path/to/puppeteer
```

### Path Configuration

MCP servers installed with `uv tool install` are located at:

```bash
# On macOS/Linux
~/.local/bin/
```

Make sure this path is in your system PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Or run `uv tool update-shell` to update your shell configuration.

## Working with uv

### Installing Tools

```bash
# Install a Python tool globally
uv tool install <tool-name>

# Update a tool
uv tool install <tool-name> --upgrade

# List installed tools
uv tool list

# Find the bin directory for installed tools
uv tool dir --bin
```

### Virtual Environments

If you need to develop an MCP server or extend one, create a virtual environment:

```bash
# Create a virtual environment for development
uv venv my-mcp-project
cd my-mcp-project
source .venv/bin/activate  # On macOS/Linux

# Install dependencies in the virtual environment
uv pip install <package-name>
```

## Configuration in claude_desktop_config.json

When configuring the MCP servers in Claude Desktop, use the correct paths:

```json
{
  "mcpServers": {
    "time": {
      "command": "/Users/username/.local/bin/mcp-server-time",
      "args": ["--local-timezone=America/Los_Angeles"]
    },
    "filesystem": {
      "command": "/path/to/node",
      "args": [
        "/path/to/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js",
        "/path/to/directory1",
        "/path/to/directory2"
      ]
    },
    "sqlite": {
      "command": "bash",
      "args": [
        "-c",
        "docker attach claude-desktop-sqlite || docker run -i --rm --name claude-desktop-sqlite -v mcp-test:/mcp mcp/sqlite --db-path /mcp/test.db"
      ]
    }
  }
}
```

The Claude Desktop config file must be placed at:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `C:\Users\USERNAME\AppData\Roaming\Claude\claude_desktop_config.json`

## Troubleshooting

- If you see `command not found` errors, check that `~/.local/bin` is in your PATH
- Use `uv tool list` to see installed tools
- Use `uv tool dir --bin` to find the location of installed tools
- If a Python MCP server doesn't work, try installing with `uv tool install --upgrade` to get the latest version
- For Docker-based servers, ensure Docker is running with `docker info`
