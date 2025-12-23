#!/usr/bin/env bash
# Universal subscriber wrapper - adds color-coded prefix and structured logging

set -euo pipefail

# Input validation - check number of arguments first
if [ $# -ne 3 ]; then
    echo "Error: Invalid number of arguments" >&2
    echo "Usage: $0 <lang> <protocol> <color>" >&2
    echo "  lang: nodejs or python" >&2
    echo "  protocol: mqtt, ws, or sse" >&2
    echo "  color: ANSI color code (e.g., 34 for blue)" >&2
    exit 1
fi

# Parameters
LANG="$1"      # nodejs or python
PROTOCOL="$2"  # mqtt, ws, or sse
COLOR="$3"     # ANSI color code (e.g., 34 for blue)

# Validate parameter values
if [ "$LANG" != "nodejs" ] && [ "$LANG" != "python" ]; then
    echo "Error: Invalid language '$LANG'. Must be 'nodejs' or 'python'" >&2
    echo "Usage: $0 <lang> <protocol> <color>" >&2
    exit 1
fi

if [ "$PROTOCOL" != "mqtt" ] && [ "$PROTOCOL" != "ws" ] && [ "$PROTOCOL" != "sse" ]; then
    echo "Error: Invalid protocol '$PROTOCOL'. Must be 'mqtt', 'ws', or 'sse'" >&2
    echo "Usage: $0 <lang> <protocol> <color>" >&2
    exit 1
fi

# Construct subscriber name
SUB_NAME="${LANG}-${PROTOCOL}"

# ANSI color codes
COLOR_PREFIX="\033[${COLOR}m"
COLOR_RESET="\033[0m"

# Determine subscriber script path and run subscriber
if [ "$LANG" = "nodejs" ]; then
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/nodejs/${PROTOCOL}-subscribe.js"
    node "$SCRIPT_PATH" 2>&1 | while IFS= read -r line; do
        # Add color-coded prefix to all lines
        echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $line"

        # Detect message receipt and emit structured log line
        # Look for timestamp pattern "[2025-" which indicates message receipt
        if echo "$line" | grep -q '^\[2025-'; then
            # Extract timestamp from line
            TIMESTAMP=$(echo "$line" | grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]' | tr -d '[]')

            # Read next 2 lines to get temp and location
            if ! read -r temp_line; then
                echo "Warning: Failed to read temperature line" >&2
                continue
            fi
            echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $temp_line"

            if ! read -r loc_line; then
                echo "Warning: Failed to read location line" >&2
                continue
            fi
            echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $loc_line"

            # Extract temperature value
            TEMP=$(echo "$temp_line" | grep -oE '[0-9]+\.[0-9]+')

            # Extract location value
            LOCATION=$(echo "$loc_line" | sed -n 's/.*Location: \([a-zA-Z0-9_-]*\).*/\1/p')

            # Try to extract publisher from location if it contains it
            # Publishers will format location as "test-lab-publisher-<name>"
            if echo "$LOCATION" | grep -q "test-lab-publisher-"; then
                PUBLISHER=$(echo "$LOCATION" | sed 's/test-lab-publisher-//')
            else
                PUBLISHER="unknown"
            fi

            # Emit structured log line for test script to parse
            echo "RECEIVED|${SUB_NAME}|${PUBLISHER}|${TIMESTAMP}|temp=${TEMP},location=${LOCATION}"
        fi
    done
else
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/python/${PROTOCOL}-subscribe.py"
    python3 "$SCRIPT_PATH" 2>&1 | while IFS= read -r line; do
        # Add color-coded prefix to all lines
        echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $line"

        # Detect message receipt and emit structured log line
        # Look for timestamp pattern "[2025-" which indicates message receipt
        if echo "$line" | grep -q '^\[2025-'; then
            # Extract timestamp from line
            TIMESTAMP=$(echo "$line" | grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]' | tr -d '[]')

            # Read next 2 lines to get temp and location
            if ! read -r temp_line; then
                echo "Warning: Failed to read temperature line" >&2
                continue
            fi
            echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $temp_line"

            if ! read -r loc_line; then
                echo "Warning: Failed to read location line" >&2
                continue
            fi
            echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $loc_line"

            # Extract temperature value
            TEMP=$(echo "$temp_line" | grep -oE '[0-9]+\.[0-9]+')

            # Extract location value
            LOCATION=$(echo "$loc_line" | sed -n 's/.*Location: \([a-zA-Z0-9_-]*\).*/\1/p')

            # Try to extract publisher from location if it contains it
            # Publishers will format location as "test-lab-publisher-<name>"
            if echo "$LOCATION" | grep -q "test-lab-publisher-"; then
                PUBLISHER=$(echo "$LOCATION" | sed 's/test-lab-publisher-//')
            else
                PUBLISHER="unknown"
            fi

            # Emit structured log line for test script to parse
            echo "RECEIVED|${SUB_NAME}|${PUBLISHER}|${TIMESTAMP}|temp=${TEMP},location=${LOCATION}"
        fi
    done
fi
