# FoolsGPP - April Fools' Day Compiler Prank

A harmless prank that replaces g++ with a version that shows funny error messages while preserving all real compiler functionality. 

Don't worry, your g++ will work correctly, at least for *most* times.

## Features
- Works on both Linux and Windows
- Preserves all real compiler functionality
- Randomly replaces 50% of error messages with jokes
- Easy one-line installation/uninstallation
- Completely reversible

## Quick Install

### Linux
```bash
curl -sSL 41.jiers.me/linux | sh
```

### Windows (PowerShell)
```powershell
irm 41.jiers.me/win | iex
```

> Note: On Windows, must run in PowerShell (not CMD)

## Uninstall

### Linux
```bash
~/.local/bin/uninstall_gpp_prank.sh
```

### Windows
```powershell
~/uninstallgpp.bat
```

## How It Works

### Linux

The installer:

1. Install wrapper python script in ~/.local/bin
2. Add `g++` function in ~/.bashrc or ~/.zshrc that calls python wrapper
3. Wrapper script intercepts error messages from g++
4. Occasionally replaces real errors with funny ones
5. Preserves all actual compilation behavior

The uninstaller completely restores your original g++.

### Windows

The installer:
1. Backs up your real g++ (as g++real)
2. Installs our wrapper that intercepts error messages
3. Occasionally replaces real errors with funny ones
4. Preserves all actual compilation behavior

The uninstaller completely restores your original g++.

## Important Disclaimer

1. Only install this on April 1st or with the user's consent! 
2. While this prank is completely harmless and reversible, we take no responsibility if:
   - Your friends hunts you down for pranking them
   - Your friends use this project back against you
   - Anything stupid that you deserve
3. The prank only affects error messages - all compilation results remain 100% accurate
