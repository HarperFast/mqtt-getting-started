#!/bin/bash
# Install MQTTX CLI and dependencies

set -e  # Exit on error

echo "Installing MQTTX CLI and dependencies..."
echo ""

# Detect platform
PLATFORM=$(uname -s)

case "$PLATFORM" in
    Darwin*)
        echo "Detected: macOS"
        echo ""

        # Install MQTTX CLI
        echo "Installing MQTTX CLI..."
        if command -v mqttx &> /dev/null; then
            echo "MQTTX CLI is already installed ($(mqttx --version))"
        else
            # Try Homebrew first
            if command -v brew &> /dev/null; then
                echo "Using Homebrew..."
                brew install emqx/mqttx/mqttx-cli
            else
                # Fallback to curl
                echo "Homebrew not found. Using curl to download binary..."

                # Detect architecture
                ARCH=$(uname -m)
                if [ "$ARCH" = "arm64" ]; then
                    MQTTX_BINARY="mqttx-cli-macos-arm64"
                else
                    MQTTX_BINARY="mqttx-cli-macos-x64"
                fi

                # Use latest stable version
                MQTTX_VERSION="v1.10.1"
                MQTTX_URL="https://www.emqx.com/zh/downloads/MQTTX/${MQTTX_VERSION}/${MQTTX_BINARY}"

                echo "Downloading from: $MQTTX_URL"
                curl -LO "$MQTTX_URL"

                echo "Installing to /usr/local/bin/mqttx (requires sudo)..."
                sudo install "./${MQTTX_BINARY}" /usr/local/bin/mqttx

                # Clean up
                rm "./${MQTTX_BINARY}"

                echo "MQTTX CLI installed successfully"
            fi
        fi

        # Install jq for JSON parsing
        echo ""
        echo "Installing jq for JSON parsing..."
        if command -v jq &> /dev/null; then
            echo "jq is already installed ($(jq --version))"
        else
            if command -v brew &> /dev/null; then
                echo "Using Homebrew..."
                brew install jq
            else
                echo "Homebrew not found. Using curl to download jq binary..."

                # Detect architecture
                ARCH=$(uname -m)
                if [ "$ARCH" = "arm64" ]; then
                    JQ_ARCH="arm64"
                else
                    JQ_ARCH="amd64"
                fi

                JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-${JQ_ARCH}"
                echo "Downloading from: $JQ_URL"

                curl -sL "$JQ_URL" -o /tmp/jq
                chmod +x /tmp/jq

                echo "Installing to /usr/local/bin/jq (requires sudo)..."
                sudo mv /tmp/jq /usr/local/bin/jq

                echo "jq installed successfully"
            fi
        fi
        ;;

    Linux*)
        echo "Detected: Linux"
        echo ""

        # Check if npm is installed
        if ! command -v npm &> /dev/null; then
            echo "Error: npm is not installed."
            echo "Please install Node.js and npm first."
            exit 1
        fi

        # Install MQTTX CLI via npm
        echo "Installing MQTTX CLI via npm..."
        if command -v mqttx &> /dev/null; then
            echo "MQTTX CLI is already installed ($(mqttx --version))"
        else
            npm install -g @emqx/mqttx-cli
        fi

        # Install jq
        echo ""
        echo "Installing jq for JSON parsing..."
        if command -v jq &> /dev/null; then
            echo "jq is already installed ($(jq --version))"
        else
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y jq
            elif command -v yum &> /dev/null; then
                sudo yum install -y jq
            else
                echo "Warning: Could not install jq automatically. Please install manually."
            fi
        fi
        ;;

    *)
        echo "Error: Unsupported platform: $PLATFORM"
        echo "Please install MQTTX CLI manually:"
        echo "  npm install -g @emqx/mqttx-cli"
        exit 1
        ;;
esac

echo ""
echo "✓ Installation complete!"
echo ""
echo "Verify installation:"
echo "  mqttx --version"
echo "  jq --version"
