#!/usr/bin/env bash
# Universal subscriber wrapper - adds color-coded prefix and structured logging

set -euo pipefail

# Parameters
LANG="$1"      # nodejs or python
PROTOCOL="$2"  # mqtt, ws, or sse
COLOR="$3"     # ANSI color code (e.g., 34 for blue)

# Construct subscriber name
SUB_NAME="${LANG}-${PROTOCOL}"

# ANSI color codes
COLOR_PREFIX="\033[${COLOR}m"
COLOR_RESET="\033[0m"

# Determine subscriber script path
if [ "$LANG" = "nodejs" ]; then
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/nodejs/${PROTOCOL}-subscribe.js"
    CMD="node $SCRIPT_PATH"
else
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/python/${PROTOCOL}-subscribe.py"
    CMD="python3 $SCRIPT_PATH"
fi

# Run subscriber and process output
$CMD 2>&1 | while IFS= read -r line; do
    # Add color-coded prefix to all lines
    echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $line"

    # Detect message receipt and emit structured log line
    # Look for timestamp pattern "[2025-" which indicates message receipt
    if echo "$line" | grep -q '^\[2025-'; then
        # Extract timestamp from line
        TIMESTAMP=$(echo "$line" | grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]' | tr -d '[]')

        # Read next 2 lines to get temp and location
        read -r temp_line
        echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $temp_line"
        read -r loc_line
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
