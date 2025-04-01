#!/bin/bash

# Exit on error and undefined variables
set -eu

# Define paths
PY_SCRIPT_NAME="g++_prank.py"
BIN_DIR="$HOME/.local/bin"
PY_SCRIPT_PATH="$BIN_DIR/$PY_SCRIPT_NAME"
UNINSTALL_SCRIPT_PATH="$BIN_DIR/uninstall_gpp_prank.sh"

# Create .local/bin if it doesn't exist
mkdir -p "$BIN_DIR"

# Function to get user's default shell
get_default_shell() {
  # Try to get from /etc/passwd first
  local shell=$(getent passwd "$(whoami)" | cut -d: -f7)
  shell=${shell:-$SHELL} # Fallback to $SHELL if empty

  case "$shell" in
  *zsh*) echo "zsh" ;;
  *bash*) echo "bash" ;;
  *) echo "bash" ;; # Default to bash if unknown
  esac
}

# Determine the correct config file
DEFAULT_SHELL=$(get_default_shell)
case "$DEFAULT_SHELL" in
zsh)
  SHELL_CONFIG="$HOME/.zshrc"
  ;;
bash)
  SHELL_CONFIG="$HOME/.bashrc"
  ;;
*)
  SHELL_CONFIG="$HOME/.bashrc"
  echo "Warning: Unknown shell, defaulting to bash"
  ;;
esac

# Create the Python script
cat >"$PY_SCRIPT_PATH" <<'EOF'
#!/usr/bin/env python3

import subprocess
import sys
import random

REAL_GPP = "g++"
TARGET_ERROR_PATTERN = r": error: "
APRIL_FOOLS_MESSAGES = [
    "April Fools! Maybe you're debugging in the Twilight Zone?",
    "Your code has been abducted by aliens. Try again after they return it.",
    "Compilation failed because the compiler found your logic too complex for mere mortals.",
    "Segmentation fault in the compiler's sense of humor. Please try again.",
    "The compiler is on strike. It demands better jokes in comments.",
    "Your code is too perfect. The compiler suspects AI-generated content.",
    "It compiles on *my* machine...",
    "Maybe your code is haunted?",
    "KFC Crazy Thursday V me 50",
    "You forgot to pray before compiling. Be sincere.",
    "Oops! I don't like your code style. Try again.",
]
CHANCE = 2  # 1 in 2 chance


def main():
    # Execute the real g++ and capture its output (both stdout and stderr)
    try:
        result = subprocess.run(
            [REAL_GPP] + sys.argv[1:], capture_output=True, text=True, check=False
        )
        stdout = result.stdout
        stderr = result.stderr
        exit_code = result.returncode

    except FileNotFoundError:
        print(
            f"Error: Real g++ not found at {
                REAL_GPP}.  Adjust REAL_GPP in the script.",
            file=sys.stderr,
        )
        sys.exit(1)

    if exit_code != 0:
        # Process the stderr
        modified_stderr = ""
        for line in stderr.splitlines():
            if TARGET_ERROR_PATTERN in line:
                if random.randint(0, CHANCE - 1) == 0:
                    # Split the line at the error message
                    parts = line.split(TARGET_ERROR_PATTERN, 1)
                    # Keep the original colorful prefix but change the message
                    modified_stderr += parts[0] + TARGET_ERROR_PATTERN
                    modified_stderr += random.choice(
                        APRIL_FOOLS_MESSAGES) + "\n"
                else:
                    modified_stderr += line + "\n"
            else:
                modified_stderr += line + "\n"

        # Print to stderr with original color codes preserved
        print(modified_stderr, file=sys.stderr, end="")
    else:
        # Print original stderr (usually empty)
        print(stderr, file=sys.stderr, end="")

    # Print original stdout (with colors preserved)
    print(stdout, end="")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()

EOF

# Make the Python script executable
chmod +x "$PY_SCRIPT_PATH"

# Create the uninstaller script
cat >"$UNINSTALL_SCRIPT_PATH" <<EOF
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
EOF

# Make the uninstaller executable
chmod +x "$UNINSTALL_SCRIPT_PATH"

# Add the g++ function to shell config
if ! grep -q "g++()" "$SHELL_CONFIG"; then
  cat >>"$SHELL_CONFIG" <<EOF

# g++ wrapper for April Fools' prank
g++() {
    if [ -f "$PY_SCRIPT_PATH" ]; then
        "$PY_SCRIPT_PATH" "\$@"
    else
        command g++ "\$@"
    fi
}
EOF
  echo "Added g++ wrapper to $SHELL_CONFIG"
else
  echo "g++ wrapper already exists in $SHELL_CONFIG"
fi

echo "Installation complete!"
echo "The prank g++ wrapper has been installed to $PY_SCRIPT_PATH"
echo "To uninstall, run: $UNINSTALL_SCRIPT_PATH"
