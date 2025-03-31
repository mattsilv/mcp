# MCP Servers

This repository contains configuration and setup for various Model Context Protocol (MCP) servers to use with Claude Desktop and other AI assistants.

## Introduction

This project was created to streamline the setup and management of MCP servers for use with Claude products. I primarily use this setup with Claude Desktop and Claude Code on Mac OS X, and I'm planning to integrate it with Cursor in the future.

If you're using Windows, you can use this as a general guide, but you'll want to adjust paths and commands accordingly.

This configuration was developed with the help of Claude through Cursor's agent view and web search to ensure we follow best practices. It's designed to be secure, flexible, and easy to maintain.

## MCP Organization Best Practices

### Directory Structure

We follow these conventions for organizing MCP-related files:

```
~/mcp/                         # Main MCP projects directory
├── .venv/                     # Python virtual environment for project-specific MCP servers
├── claude_desktop_config.json # Reference config file
├── README.md                  # This documentation
├── install-config.sh          # Installation script
├── setup-mcp-secrets.sh       # Secrets setup script
└── uv_notes.md                # Notes on using uv for Python dependencies
```

### Virtual Environment Management

For Python-based MCP servers, we follow these conventions:

1. **Project-specific MCP servers**:

   - Create a project-local virtual environment in the project directory
   - Install MCP servers within this environment using `uv`
   - Example: `cd ~/mcp && uv venv && source .venv/bin/activate`

2. **Global MCP servers**:
   - Install using `uv tool install <server-name>`
   - These are available at `~/.local/bin/`

### Dependency Management

Always use `uv` for Python package management:

- Tool installation: `uv tool install <tool-name>`
- Virtual env creation: `uv venv`
- Package installation: `uv pip install <package-name>`

## Installed MCP Servers

The following MCP servers have been installed and configured:

1. **Filesystem** - Access files and directories on your local filesystem

   - Installed via: `npm install -g @modelcontextprotocol/server-filesystem`
   - Configure with paths to directories you want to access

2. **SQLite** - Query SQLite databases

   - Installed via: `uv tool install mcp-server-sqlite`
   - Configure with paths to your database files

   **SQLite Database Registry:**

   To add multiple project databases, update the SQLite configuration in `claude_desktop_config.json`:

   ```json
   "sqlite": {
     "command": "path/to/mcp-server-sqlite",
     "args": [
       "--db-path",
       "path/to/your/database.db"
     ],
     "env": {
       "MCP_SQLITE_REGISTRY": "path/to/db1.sqlite:path/to/db2.db:path/to/db3.sqlite"
     }
   }
   ```

   Then access these databases in Claude by specifying the full path:

   ```sql
   -- Query first database
   SELECT * FROM users WHERE id = 1 -- Using path/to/db1.sqlite

   -- Switch to second database
   USE DATABASE path/to/db2.db;
   SELECT * FROM products;
   ```

   **Important:** Always restart Claude Desktop after making changes to the configuration file.

3. **Puppeteer** - Web browsing and automation

   - Installed via: `npm install -g @modelcontextprotocol/server-puppeteer`
   - Configured to use local Chrome installation
   - Environment variables:
     - `PUPPETEER_HEADLESS`: Set to "true" for headless operation
     - `PUPPETEER_EXECUTABLE_PATH`: Points to local Chrome installation
   - Note: We use the Node.js implementation for better local network access and no Docker dependency

4. **GitHub** - Access GitHub repositories and issues

   - Installed via: `npm install -g @modelcontextprotocol/server-github`
   - Requires environment variable: `GITHUB_PERSONAL_ACCESS_TOKEN`

5. **Time** - Get current time and date information

   - Installed via: `uv tool install mcp-server-time`
   - Configure with your local timezone

6. **Fetch** - Make HTTP requests and parse web content

   - Installed via: `uv tool install mcp-server-fetch`
   - Enhanced with dual configuration for better HTTP request handling
   - Added environment variables to nudge Claude to prefer fetch for HTTP requests

7. **CLI** - Execute commands securely
   - Installed in project virtual environment: `cd ~/mcp && source .venv/bin/activate && uv pip install cli-mcp-server`
   - Configured for HTTP operations with appropriate permissions

## Configuration

The Claude Desktop configuration file is located at:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `C:\Users\USERNAME\AppData\Roaming\Claude\claude_desktop_config.json`

### Setting Up Your Configuration

This repository includes two configuration files:

- `claude_desktop_config.template.json` - A template with placeholders for paths and settings
- Your actual configuration file (excluded from git by default)

To set up your configuration:

1. Create a custom configuration file:

```bash
cp claude_desktop_config.template.json claude_desktop_config.custom.json
```

2. Edit your custom configuration file to include your specific paths and settings:

```bash
# Edit with your preferred text editor
nano claude_desktop_config.custom.json
```

3. Install your configuration:

```bash
# On macOS
./install-config.sh

# On Windows (PowerShell)
# The install script will use your custom config
```

**Important:** After updating the configuration file, you must restart Claude Desktop for changes to take effect.

## HTTP Request Handling

We've implemented a robust strategy for HTTP requests using multiple MCP servers:

1. **Primary Fetch Server**

   - Command: `mcp-server-fetch`
   - Enhanced with custom user agent
   - Environment variables to signal Claude to prefer this method

2. **HTTP Alias Server**

   - Same fetch server with different name and configuration
   - Makes it easier for Claude to recognize when HTTP requests should be made

3. **CLI Server Fallback**
   - Handles curl, wget, and http commands
   - Configured with appropriate flags for common HTTP operations
   - Runs in project-specific virtual environment

This tiered approach ensures Claude has multiple ways to make HTTP requests, with built-in fallbacks and clear signals about which methods to prefer.

## Securely Managing Secrets

Several MCP servers require API keys, tokens, or other sensitive information. Here's the complete setup process to ensure your secrets work correctly:

### Step 1: Create Environment Variables File

Create a dedicated environment file (recommended approach):

```bash
# Create environment variables file
touch ~/.claude_env
chmod 600 ~/.claude_env  # Restrict permissions for security
```

Add your secrets to this file (one per line):

```
CLAUDE_DESKTOP_GITHUB_TOKEN=your_github_token_here
BRAVE_API_KEY=your_brave_api_key_here
# Add other secrets as needed
```

### Step 2: Ensure Variables Are Loaded

Add code to your shell profile to automatically load these variables when a shell starts:

```bash
# Open your shell profile
echo 'if [ -f ~/.claude_env ]; then
  export $(grep -v "^#" ~/.claude_env | xargs)
fi' >> ~/.zshrc  # Or ~/.bashrc for bash users
```

Then reload your profile:

```bash
source ~/.zshrc  # Or ~/.bashrc
```

### Step 3: Verify Environment Variables

Verify the variables are properly loaded:

```bash
# Should display the first few characters of your token
echo ${CLAUDE_DESKTOP_GITHUB_TOKEN:0:5}...
```

### Step 4: Test API Access (Optional but Recommended)

For GitHub, test that your token works:

```bash
curl -s -H "Authorization: token $CLAUDE_DESKTOP_GITHUB_TOKEN" https://api.github.com/user | grep login
```

### Step 5: Reference in Configuration

Your `claude_desktop_config.json` should reference these variables:

```json
"github": {
  "command": "path/to/node",
  "args": [
    "path/to/server-github/dist/index.js"
  ],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${CLAUDE_DESKTOP_GITHUB_TOKEN}"
  }
}
```

### Step 6: Restart Claude Desktop

Completely quit and restart Claude Desktop to pick up the new environment variables.

### Automated Setup Script

This repository includes `setup-mcp-secrets.sh` which automates the above steps.

## Troubleshooting

### Common Issues

1. **"Authentication Failed: Bad credentials" error**

   - **Problem**: Environment variables are defined but not loaded into Claude Desktop's environment
   - **Solution**: Ensure your shell profile loads the variables and restart Claude Desktop
   - **Verification**: Run `echo $CLAUDE_DESKTOP_GITHUB_TOKEN` in terminal to check if the variable is set

2. **Environment variables not persisting**

   - **Problem**: Variables are set temporarily but don't persist across sessions
   - **Solution**: Ensure the loading code is in your shell profile and the file path is correct
   - **Fix**: Check for typos in both the variable name and the file paths

3. **API access works in terminal but not in Claude Desktop**

   - **Problem**: GUI applications sometimes don't inherit all environment variables
   - **Solution**: Log out and log back in, or restart your computer
   - **Alternative**: Try launching Claude Desktop from terminal with `open -a "Claude"`

4. **"Target closed" errors with Puppeteer**

   - **Problem**: Architecture mismatch on Apple Silicon Macs
   - **Solution**: Ensure you're using a compatible Puppeteer configuration for your architecture

5. **"Received request before initialization was complete" error with SQLite**

   - **Problem**: The SQLite MCP server not starting correctly
   - **Solution**:
     1. Install with uv: `uv tool install mcp-server-sqlite`
     2. Update your config to use the global path
     3. Restart Claude Desktop completely

6. **MCP changes not taking effect**

   - **Problem**: Claude Desktop caches configuration
   - **Solution**: Always completely restart Claude Desktop after config changes

7. **Claude tries to use curl instead of fetch server**

   - **Problem**: Claude isn't correctly recognizing the fetch server for HTTP requests
   - **Solution**:
     1. Add environment variables to signal preference (`MCP_FETCH_PREFERRED: "true"`)
     2. Create an HTTP alias server as shown in our configuration
     3. Add CLI server as a fallback for curl commands

8. **JSON parsing errors with fetch MCP server**

   - **Problem**: Errors like "Unexpected end of JSON input" or "Unexpected token" when fetching web content
   - **Symptoms**: Multiple error messages appearing when Claude tries to search or fetch content from websites
   - **Solution**:
     1. Configure the fetch server with fallback parsing: `MCP_FETCH_PARSE_FALLBACK: "text"`
     2. Add `--ignore-robots-txt` to the args to avoid parsing issues with robots.txt files
     3. Set appropriate timeout and max size limits
     4. Restart Claude Desktop completely after making these changes

   Example config for robust fetch server:

   ```json
   "fetch": {
     "command": "path/to/mcp-server-fetch",
     "args": [
       "--user-agent", "Claude Desktop MCP Client",
       "--ignore-robots-txt"
     ],
     "env": {
       "MCP_FETCH_PREFERRED": "true",
       "MCP_FETCH_DEFAULT": "true",
       "MCP_FETCH_PARSE_FALLBACK": "text",
       "MCP_FETCH_MAX_SIZE": "5242880",
       "MCP_FETCH_TIMEOUT": "60000"
     }
   }
   ```

## Adding Claude Desktop MCP to Claude in a Web Browser

To use your MCP servers from Claude Desktop in Claude web or Claude Code, you can run:

```bash
# On macOS
osascript -e 'tell application "Claude" to activate' && sleep 2 && osascript -e 'tell application "System Events" to keystroke "m" using {command down, shift down}'

# On Windows (PowerShell)
Start-Process "Claude" && Start-Sleep -Seconds 2 && Add-Type -AssemblyName System.Windows.Forms && [System.Windows.Forms.SendKeys]::SendWait("^+m")
```

This activates Claude Desktop and triggers the keyboard shortcut to add MCP servers to the current browser session.

## Working with uv

See [uv_notes.md](./uv_notes.md) for detailed information on working with uv for Python-based MCP servers.

## References

- [MCP Server GitHub Repository](https://github.com/modelcontextprotocol/servers)
- [MCP Installer](https://github.com/anaisbetts/mcp-installer)
- [CLI MCP Server](https://github.com/MladenSU/cli-mcp-server)
- [Building MCP Servers Guide](https://composio.dev/blog/mcp-server-step-by-step-guide-to-building-from-scrtch/)

## Security Best Practices

When working with MCP servers that require API keys and tokens, it's important to follow security best practices:

1. **Never commit sensitive information**:

   - API keys, tokens, and credentials should never be committed to your repository
   - Use environment variables and separate files that are excluded in `.gitignore`

2. **Avoid accidental commits**:

   - Use specific `git add` commands instead of catch-all `git add .`
   - Review changes with `git diff --cached` before committing
   - Set up a pre-commit hook to check for sensitive data

3. **If sensitive data is accidentally committed**:

   - Use `git filter-repo` to permanently remove it from history
   - Change any exposed credentials immediately
   - Force push the cleaned repository

4. **Configuration separation**:
   - Use template files with placeholders for sensitive values
   - Keep actual configuration files local and excluded from git
   - Our approach of separating `claude_desktop_config.template.json` from your actual config provides this protection

For more details on removing sensitive data from repositories, see GitHub's [official documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).
