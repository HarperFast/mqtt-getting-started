#!/usr/bin/env bash
# MQTT Subscriber using MQTTX CLI
# Install: npm install -g @emqx/mqttx-cli
# Or: brew install emqx/mqttx/mqttx-cli (macOS)

BROKER="localhost"
PORT="1883"
TOPIC="Sensors/101"

echo "Connected to MQTT broker"
echo "Subscribed to: $TOPIC"
echo "Listening for messages..."
echo ""

# Subscribe and parse output
# Default format: "topic: Sensors/101, qos: 1, size: 35B" followed by JSON payload
mqttx sub -h "$BROKER" -p "$PORT" -t "$TOPIC" -q 1 2>/dev/null | while IFS= read -r line; do
    # Look for topic line (e.g., "topic: Sensors/101, qos: 1, size: 35B")
    if [[ "$line" =~ ^topic:\ ([^,]+) ]]; then
        RECEIVED_TOPIC="${BASH_REMATCH[1]}"
        # Read the next line which should be the JSON payload
        read -r payload_line

        # Try to parse as JSON
        if echo "$payload_line" | jq . > /dev/null 2>&1; then
            TEMP=$(echo "$payload_line" | jq -r '.temp')
            LOCATION=$(echo "$payload_line" | jq -r '.location')
            TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

            echo "[$TIMESTAMP] Update on $RECEIVED_TOPIC:"
            echo "  Temperature: ${TEMP}°F"
            echo "  Location: $LOCATION"
            echo ""
        fi
    fi
done
