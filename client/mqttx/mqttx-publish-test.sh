#!/usr/bin/env bash
# MQTTX Test Publisher - accepts JSON payload as command-line argument
# Usage: ./mqttx-publish-test.sh '{"temp":72.5,"location":"test-lab"}'

BROKER="localhost"
PORT="1883"
TOPIC="Sensors/101"

if [ $# -lt 1 ]; then
    echo "Usage: $0 '{\"temp\":72.5,\"location\":\"test-lab\"}'"
    exit 1
fi

PAYLOAD="$1"

echo "Connected to MQTT broker"
echo "Published: $PAYLOAD"

mqttx pub -h "$BROKER" -p "$PORT" -t "$TOPIC" -m "$PAYLOAD" -q 1 --retain
