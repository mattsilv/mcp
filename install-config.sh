#!/bin/bash

# Script to copy Claude Desktop config file to the correct location
# This ensures the MCP servers configuration is properly installed

# Determine source config - use custom if it exists, otherwise use template
if [ -f "./claude_desktop_config.custom.json" ]; then
    SOURCE_CONFIG="./claude_desktop_config.custom.json"
    echo "Using custom configuration file"
elif [ -f "./claude_desktop_config.json" ] && [ ! -f "./claude_desktop_config.custom.json" ]; then
    SOURCE_CONFIG="./claude_desktop_config.json"
    echo "Using existing configuration file"
else
    echo "No custom configuration found. Please create one by copying the template:"
    echo "cp claude_desktop_config.template.json claude_desktop_config.custom.json"
    echo "Then edit claude_desktop_config.custom.json with your specific paths and settings."
    exit 1
fi

# Define destination path
DEST_DIR="$HOME/Library/Application Support/Claude"
DEST_CONFIG="$DEST_DIR/claude_desktop_config.json"

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Creating directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# Check if source config exists
if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "Error: Source config file not found: $SOURCE_CONFIG"
    exit 1
fi

# Backup existing config if it exists
if [ -f "$DEST_CONFIG" ]; then
    BACKUP_FILE="$DEST_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing config to: $BACKUP_FILE"
    cp "$DEST_CONFIG" "$BACKUP_FILE"
fi

# Copy config file
echo "Copying config file to: $DEST_CONFIG"
cp "$SOURCE_CONFIG" "$DEST_CONFIG"

# Check if copy was successful
if [ $? -eq 0 ]; then
    echo "Success! Claude Desktop config has been installed."
    echo "You can now start or restart the Claude Desktop app."
else
    echo "Error: Failed to copy config file."
    exit 1
fi

exit 0 