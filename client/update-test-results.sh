#!/usr/bin/env bash
# Update README.md with test results

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="$PROJECT_ROOT/README.md"
RESULTS_DIR="$1"

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Get publisher labels
get_pub_label() {
    case "$1" in
        "nodejs-mqtt") echo "Node.js MQTT" ;;
        "nodejs-ws") echo "Node.js WS" ;;
        "python-mqtt") echo "Python MQTT" ;;
        "python-ws") echo "Python WS" ;;
        "mqttx-mqtt") echo "MQTTX MQTT" ;;
    esac
}

# Generate table
generate_table() {
    echo "Last run: $TIMESTAMP"
    echo ""

    # Subscriber names
    local subscribers=(
        "nodejs-mqtt"
        "nodejs-ws"
        "nodejs-sse"
        "python-mqtt"
        "python-ws"
        "python-sse"
        "mqttx-mqtt"
    )

    # Print table header
    echo -n "| Publisher (rows) / Subscriber (columns) |"
    for sub in "${subscribers[@]}"; do
        echo -n " $sub |"
    done
    echo ""

    # Print separator
    echo -n "|----------------------------------------|"
    for sub in "${subscribers[@]}"; do
        echo -n "-------------|"
    done
    echo ""

    # Print results for each publisher
    for key in "nodejs-mqtt" "nodejs-ws" "python-mqtt" "python-ws" "mqttx-mqtt"; do
        pub_label=$(get_pub_label "$key")
        echo -n "| $pub_label |"

        if [ -f "$RESULTS_DIR/$key" ]; then
            # Read per-subscriber results
            results=$(cat "$RESULTS_DIR/$key")

            for sub in "${subscribers[@]}"; do
                # Extract status for this subscriber
                status=$(echo "$results" | grep -o "$sub:[^|]*" | cut -d: -f2)

                if [ -z "$status" ]; then
                    status="⚪️"
                fi

                echo -n " $status |"
            done
        else
            # No results file - mark all as not tested
            for sub in "${subscribers[@]}"; do
                echo -n " ⚪️ |"
            done
        fi
        echo ""
    done
}

# Create temp file
TEMP_README=$(mktemp)

# Update README between markers
{
    # Print everything up to TEST_RESULTS_START
    sed -n '1,/<!-- TEST_RESULTS_START -->/p' "$README"

    # Print new results
    echo ""
    generate_table
    echo ""

    # Print everything after TEST_RESULTS_END
    sed -n '/<!-- TEST_RESULTS_END -->/,$p' "$README"
} > "$TEMP_README"

mv "$TEMP_README" "$README"

echo "📝 Updated README with test results"
