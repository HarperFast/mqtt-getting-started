#!/usr/bin/env bash
# Launch all 6 subscribers in tmux with 2x3 grid layout

set -euo pipefail

SESSION_NAME="mqtt-test-subscribers"
WRAPPER="/Users/ivan/Projects/mqtt-getting-started/client/wrappers/wrap-subscriber.sh"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    echo "Install with: brew install tmux (macOS) or apt-get install tmux (Linux)"
    exit 1
fi

# Handle stop command
if [ "${1:-}" = "stop" ]; then
    echo "Stopping all subscribers..."
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null || echo "No session to stop"
    exit 0
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists."
    echo "Run '$0 stop' to kill it first, or attach with: tmux attach -t $SESSION_NAME"
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

echo "Starting all subscribers in tmux session: $SESSION_NAME"
echo "Layout: 2x3 grid (top row: nodejs, bottom row: python)"
echo ""
echo "To view: tmux attach -t $SESSION_NAME"
echo "To stop: $0 stop"
echo ""

# Create new tmux session with first pane (nodejs-mqtt)
tmux new-session -d -s "$SESSION_NAME" "$WRAPPER nodejs mqtt 34"

# Split window into 2x3 grid
# Top row: nodejs-mqtt, nodejs-ws, nodejs-sse
tmux split-window -h -t "$SESSION_NAME" "$WRAPPER nodejs ws 36"
tmux split-window -h -t "$SESSION_NAME" "$WRAPPER nodejs sse 32"

# Bottom row: python-mqtt, python-ws, python-sse
tmux select-pane -t "$SESSION_NAME:0.0"
tmux split-window -v -t "$SESSION_NAME" "$WRAPPER python mqtt 33"
tmux select-pane -t "$SESSION_NAME:0.1"
tmux split-window -v -t "$SESSION_NAME" "$WRAPPER python ws 35"
tmux select-pane -t "$SESSION_NAME:0.2"
tmux split-window -v -t "$SESSION_NAME" "$WRAPPER python sse 31"

# Balance the layout
tmux select-layout -t "$SESSION_NAME" tiled

echo "All subscribers started!"
echo ""
echo "Attach to view: tmux attach -t $SESSION_NAME"
echo "Detach once inside: Ctrl+b then d"
echo "Stop all: $0 stop"
