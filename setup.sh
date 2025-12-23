#!/usr/bin/env bash
# Setup script for mqtt-getting-started project

set -euo pipefail

echo "========================================="
echo "MQTT Getting Started - Setup"
echo "========================================="
echo ""

# Check if pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "Error: pyenv is not installed"
    echo "Install pyenv first: https://github.com/pyenv/pyenv#installation"
    exit 1
fi

# Check if the virtualenv exists
if ! pyenv versions | grep -q "mqtt-getting-started"; then
    echo "Creating Python virtual environment..."
    pyenv virtualenv 3.11 mqtt-getting-started
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Set local Python version
echo "Setting local Python version..."
pyenv local mqtt-getting-started
echo "✓ .python-version configured"

# Install Python dependencies
echo ""
echo "Installing Python dependencies..."
pip install -r requirements.txt
echo "✓ Python dependencies installed"

# Install Node.js dependencies for Harper
echo ""
echo "Installing Harper dependencies..."
cd harper
npm install
cd ..
echo "✓ Harper dependencies installed"

# Install Node.js client dependencies
echo ""
echo "Installing Node.js client dependencies..."
cd client/nodejs
npm install
cd ../..
echo "✓ Node.js client dependencies installed"

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Start Harper:  cd harper && npm run dev"
echo "  2. Run tests:     cd client && ./test.sh"
echo ""
