#!/bin/bash
# MQTT Subscriber using MQTTX CLI
# Install: npm install -g @emqx/mqttx-cli
# Or: brew install emqx/mqttx/mqttx-cli (macOS)

BROKER="localhost"
PORT="1883"

# Subscribe to sensor 101 topic:
TOPIC="Sensors/101"
# Subscribe to all sensor topics (Sensors/101, Sensors/102, etc.)
# TOPIC="Sensors/#"

echo "Connected to MQTT broker"
echo "Subscribed to: $TOPIC"
echo "Listening for messages... (Ctrl+C to stop)"
echo ""

# Subscribe and listen for messages
# -v: verbose mode (shows topic, QoS, and retain flag)
# --format: json output format for easier parsing
mqttx sub -h "$BROKER" -p "$PORT" -t "$TOPIC" -q 1 -v --format json | while IFS= read -r line; do
    # Parse JSON output from mqttx
    if echo "$line" | jq . > /dev/null 2>&1; then
        RECEIVED_TOPIC=$(echo "$line" | jq -r '.topic')
        MESSAGE=$(echo "$line" | jq -r '.payload')
        TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

        # Try to parse message as JSON
        if echo "$MESSAGE" | jq . > /dev/null 2>&1; then
            TEMP=$(echo "$MESSAGE" | jq -r '.temp')
            LOCATION=$(echo "$MESSAGE" | jq -r '.location')

            echo "[$TIMESTAMP] Update on $RECEIVED_TOPIC:"
            echo "  Temperature: ${TEMP}°F"
            echo "  Location: $LOCATION"
            echo ""
        else
            # If message isn't JSON, just print as-is
            echo "[$TIMESTAMP] Update on $RECEIVED_TOPIC: $MESSAGE"
            echo ""
        fi
    else
        # Fallback if mqttx output isn't JSON
        echo "$line"
    fi
done
