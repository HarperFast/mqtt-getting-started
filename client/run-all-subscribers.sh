#!/usr/bin/env bash
# Launch all 6 subscribers in background with output capture

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/test-logs"
PID_FILE="$LOG_DIR/subscribers.pids"

# Handle stop command
if [ "${1:-}" = "stop" ]; then
    echo "Stopping all subscribers..."
    if [ -f "$PID_FILE" ]; then
        while read pid; do
            kill "$pid" 2>/dev/null || true
        done < "$PID_FILE"
        rm -f "$PID_FILE"
        echo "All subscribers stopped"
    else
        echo "No subscribers running"
    fi
    exit 0
fi

# Check if already running
if [ -f "$PID_FILE" ]; then
    echo "Subscribers already running (PID file exists)"
    echo "Run '$0 stop' to stop them first"
    exit 1
fi

# Check if Harper is running
if ! nc -z localhost 9926 2>/dev/null; then
    echo "Warning: Harper doesn't appear to be running on port 9926"
    echo "Start Harper first: cd harper && npm start"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if MQTT broker is running
if ! nc -z localhost 1883 2>/dev/null; then
    echo "Warning: MQTT broker doesn't appear to be running on port 1883"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create log directory
mkdir -p "$LOG_DIR"
rm -f "$LOG_DIR"/*.log

echo "Starting all subscribers in background..."
echo "Logs will be written to: $LOG_DIR/"
echo ""

# Start each subscriber in background
subscribers=(
    "nodejs:mqtt"
    "nodejs:ws"
    "nodejs:sse"
    "python:mqtt"
    "python:ws"
    "python:sse"
    "mqttx:mqtt"
)

for sub in "${subscribers[@]}"; do
    IFS=':' read -r lang protocol <<< "$sub"
    log_file="$LOG_DIR/${lang}-${protocol}.log"

    if [ "$lang" = "nodejs" ]; then
        node "$PROJECT_ROOT/client/nodejs/${protocol}-subscribe.js" > "$log_file" 2>&1 &
    elif [ "$lang" = "python" ]; then
        python3 "$PROJECT_ROOT/client/python/${protocol}-subscribe.py" > "$log_file" 2>&1 &
    elif [ "$lang" = "mqttx" ]; then
        "$PROJECT_ROOT/client/mqttx/mqttx-subscribe-test.sh" > "$log_file" 2>&1 &
    fi

    echo $! >> "$PID_FILE"
    echo "Started ${lang}-${protocol} (PID: $!)"
done

echo ""
echo "All subscribers started!"
echo ""
echo "To view logs:"
echo "  tail -f $LOG_DIR/*.log"
echo ""
echo "To stop all subscribers:"
echo "  $0 stop"
echo ""
