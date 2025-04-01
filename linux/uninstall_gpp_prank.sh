#!/bin/bash

# Remove the Python script
rm -f "$PY_SCRIPT_PATH"

# Remove the g++ function from shell config
TARGET_CONFIG=""
if [ -f "$HOME/.zshrc" ] && grep -q "g++()" "$HOME/.zshrc"; then
  TARGET_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ] && grep -q "g++()" "$HOME/.bashrc"; then
  TARGET_CONFIG="$HOME/.bashrc"
fi

if [ -n "\$TARGET_CONFIG" ]; then
  sed -i '/^g++() {/,/^}/d' "\$TARGET_CONFIG"
  sed -i '/^alias g++=/d' "\$TARGET_CONFIG"
  echo "Removed g++ wrapper from \$TARGET_CONFIG"
else
  echo "Warning: Could not find g++ wrapper in shell config files"
fi

# Remove this uninstaller script
rm -f "$UNINSTALL_SCRIPT_PATH"

echo "g++ prank uninstalled successfully!"
