#!/usr/bin/env bash
# Master test script - launches subscribers and runs publisher tests

set -euo pipefail

SCRIPT_DIR="/Users/ivan/Projects/mqtt-getting-started/client"
SESSION_NAME="mqtt-test-subscribers"

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "MQTT/WS/SSE Cross-Protocol Test Suite"
echo "========================================="
echo ""

# Check if Harper is running
if ! nc -z localhost 9926 2>/dev/null; then
    echo "Error: Harper is not running on port 9926"
    echo "Start Harper: cd harper && npm start"
    exit 1
fi

# Check if MQTT broker is running
if ! nc -z localhost 1883 2>/dev/null; then
    echo "Error: MQTT broker is not running on port 1883"
    echo "Make sure MQTT broker is running"
    exit 1
fi

echo -e "${BLUE}Step 1: Starting all subscribers in tmux${NC}"
echo ""

# Start subscribers
if ! "$SCRIPT_DIR/run-all-subscribers.sh"; then
    echo "Failed to start subscribers"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 2: Waiting 3s for subscribers to connect${NC}"
sleep 3

echo ""
echo -e "${BLUE}Step 3: Running publisher tests${NC}"
echo ""

# Run publisher tests
test_result=0
if ! "$SCRIPT_DIR/run-publishers.sh"; then
    test_result=1
fi

echo ""
echo -e "${YELLOW}Subscribers are still running in tmux session: $SESSION_NAME${NC}"
echo "To view: tmux attach -t $SESSION_NAME"
echo "To stop: ./run-all-subscribers.sh stop"
echo ""

# Ask if user wants to keep subscribers running
read -p "Keep subscribers running? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping subscribers..."
    "$SCRIPT_DIR/run-all-subscribers.sh" stop
    echo -e "${GREEN}Cleanup complete${NC}"
fi

exit $test_result
