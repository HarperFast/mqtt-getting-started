#!/bin/bash
# MQTT Publisher using MQTTX CLI
# Install: npm install -g @emqx/mqttx-cli
# Or: brew install emqx/mqttx/mqttx-cli (macOS)

BROKER="localhost"
PORT="1883"
TOPIC="Sensors/101"

# Generate random temperature between 65-85
TEMP=$(awk -v min=65 -v max=85 'BEGIN{srand(); print min+rand()*(max-min)}' | xargs printf "%.1f")

# Create JSON payload
PAYLOAD="{\"temp\": $TEMP, \"location\": \"warehouse\"}"

echo "Publishing to $TOPIC: $PAYLOAD"

# ============================================================
# TIER 0: MVP - Single publish, no database persistence
# ============================================================
# mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1

# # Check if publish was successful
# if [ $? -eq 0 ]; then
#     echo "Published successfully"
# else
#     echo "Publish failed"
#     exit 1
# fi

# ============================================================
# TIER 1: Enable database persistence - uncomment to enable
# Add --retain flag to retain message (enables database upsert)
# ============================================================
# mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1 --retain

# ============================================================
# TIER 2: Continuous publishing - uncomment to enable
# Publishes every 5 seconds
# ============================================================
echo "Publishing every 5 seconds... (Ctrl+C to stop)"
while true; do
    TEMP=$(awk -v min=65 -v max=85 'BEGIN{srand(); print min+rand()*(max-min)}' | xargs printf "%.1f")
    PAYLOAD="{\"temp\": $TEMP, \"location\": \"warehouse\"}"
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Publishing: $PAYLOAD"
    mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1 --retain
    sleep 5
done
