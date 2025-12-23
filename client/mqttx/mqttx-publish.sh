#!/usr/bin/env bash
# MQTT Publisher using MQTTX CLI
# Install: npm install -g @emqx/mqttx-cli
# Or: brew install emqx/mqttx/mqttx-cli (macOS)
#
# Usage:
#   ./mqttx-publish.sh                                    # Continuous publishing with auto-generated messages
#   ./mqttx-publish.sh '{"temp":72.5,"location":"test"}'  # Single publish with custom payload (for testing)

BROKER="localhost"
PORT="1883"
TOPIC="Sensors/101"

# Check retain flag (defaults to true, set MQTT_RETAIN=false for ephemeral messages)
RETAIN_FLAG=""
if [ "${MQTT_RETAIN:-true}" != "false" ]; then
    RETAIN_FLAG="--retain"
fi

# Check if custom payload provided (for testing)
if [ $# -ge 1 ]; then
    # Single publish with provided payload (for testing)
    PAYLOAD="$1"

    echo "Connected to MQTT broker"
    echo "Published: $PAYLOAD (retain: ${MQTT_RETAIN:-true})"

    mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1 $RETAIN_FLAG
else
    # Default: continuous publishing with auto-generated messages
    echo "Publishing every 5 seconds (retain: ${MQTT_RETAIN:-true})... (Ctrl+C to stop)"

    while true; do
        TEMP=$(awk -v min=65 -v max=85 'BEGIN{srand(); print min+rand()*(max-min)}' | xargs printf "%.4f")
        PAYLOAD="{\"temp\": $TEMP, \"location\": \"warehouse\"}"
        echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Publishing: $PAYLOAD"
        mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1 $RETAIN_FLAG
        sleep 5
    done
fi
