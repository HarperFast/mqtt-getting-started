#!/usr/bin/env bash
# MQTTX Test Subscriber - simplified output for test logging

BROKER="localhost"
PORT="1883"
TOPIC="Sensors/101"

echo "Connected to MQTT broker"
echo "Subscribed to: $TOPIC"
echo "Listening for messages..."
echo ""

# Subscribe and output in a format similar to other subscribers
mqttx sub -h "$BROKER" -p "$PORT" -t "$TOPIC" -q 1 --format json | while IFS= read -r line; do
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
            echo "[$TIMESTAMP] Update on $RECEIVED_TOPIC: $MESSAGE"
            echo ""
        fi
    fi
done
