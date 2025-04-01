#!/bin/bash

set -e

# Create dist directory
rm -rf dist
mkdir -p dist

# Build Windows components
echo "Building Windows components..."
GOOS=windows GOARCH=amd64 go build -o dist/g++.exe ./windows/main.go

# Copy Windows scripts
cp windows/install.ps1 dist/win

# Package Linux components
echo "Packaging Linux components..."
cp linux/install.sh dist/linux

# Create simple HTML file
echo "Creating HTML file..."
echo '<h1>April Fool!</h1>' >dist/index.html

echo "Build complete! Output in dist/"
