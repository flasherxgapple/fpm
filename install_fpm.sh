#!/bin/bash

# URL to download fpm.sh
URL="https://github.com/flasherxgapple/fpm/main/fpm.sh"

# Local bin directory
BIN_DIR="$HOME/.local/bin"

# checking bin directory
echo "checking bin directory"
sleep 2
mkdir -p "$BIN_DIR"

# Downloading file
echo "downloading fpm file"
sleep 2
wget -o "$BIN_DIR/fpm.sh" "$URL"

# Make executable
echo "make fpm executable"
chmod +x "$BIN_DIR/fpm.sh"

# Creating symlink 
ln -sf "$BIN_DIR/fpm.sh" "$BIN_DIR/fpm"

# checking bin's path
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    # For bash
    if ! grep -q "export PATH=\"$HOME/.local/bin:\$PATH\"" ~/.bashrc 2>/dev/null; then
        echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
        echo "Automatically added ~/.local/bin to PATH in ~/.bashrc"
    else
        echo "~/.local/bin already in ~/.bashrc"
    fi
    # For zsh
    if ! grep -q "export PATH=\"$HOME/.local/bin:\$PATH\"" ~/.zshrc 2>/dev/null; then
        echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> ~/.zshrc
        echo "Automatically added ~/.local/bin to PATH in ~/.zshrc"
    else
        echo "~/.local/bin already in ~/.zshrc"
    fi
    echo "Run: source ~/.bashrc or source ~/.zshrc to apply changes in current session"
fi

echo "fpm.sh installed to $BIN_DIR/fpm.sh"
echo "use 'fpm -h' for help"
echo "use 'fpm -i' for info"
