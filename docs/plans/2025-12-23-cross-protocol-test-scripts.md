# Cross-Protocol Pub/Sub Test Scripts Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create automated test suite with visual monitoring to verify cross-protocol message delivery across all publishers and subscribers.

**Architecture:** Three-layer script system: (1) Universal subscriber wrapper adds structured output, (2) tmux orchestration for visual monitoring, (3) publisher test runner with automated verification.

**Tech Stack:** Bash, tmux, awk/sed for parsing, existing Node.js/Python clients

---

## Task 1: Create Wrapper Directory

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/wrappers/`

**Step 1: Create directory**

```bash
mkdir -p /Users/ivan/Projects/mqtt-getting-started/client/wrappers
```

**Step 2: Verify directory exists**

Run: `ls -la /Users/ivan/Projects/mqtt-getting-started/client/`
Expected: Directory `wrappers/` appears in listing

**Step 3: Commit**

```bash
git add client/wrappers
git commit -m "feat: add wrappers directory for test infrastructure"
```

---

## Task 2: Create Universal Subscriber Wrapper

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/wrappers/wrap-subscriber.sh`

**Step 1: Write the subscriber wrapper script**

Create executable script that wraps any subscriber and adds structured output:

```bash
#!/usr/bin/env bash
# Universal subscriber wrapper - adds color-coded prefix and structured logging

set -euo pipefail

# Parameters
LANG="$1"      # nodejs or python
PROTOCOL="$2"  # mqtt, ws, or sse
COLOR="$3"     # ANSI color code (e.g., 34 for blue)

# Construct subscriber name
SUB_NAME="${LANG}-${PROTOCOL}"

# ANSI color codes
COLOR_PREFIX="\033[${COLOR}m"
COLOR_RESET="\033[0m"

# Determine subscriber script path
if [ "$LANG" = "nodejs" ]; then
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/nodejs/${PROTOCOL}-subscribe.js"
    CMD="node $SCRIPT_PATH"
else
    SCRIPT_PATH="/Users/ivan/Projects/mqtt-getting-started/client/python/${PROTOCOL}-subscribe.py"
    CMD="python3 $SCRIPT_PATH"
fi

# Run subscriber and process output
$CMD 2>&1 | while IFS= read -r line; do
    # Add color-coded prefix to all lines
    echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $line"

    # Detect message receipt and emit structured log line
    # Look for timestamp pattern "[2025-" which indicates message receipt
    if echo "$line" | grep -q '^\[2025-'; then
        # Extract timestamp from line
        TIMESTAMP=$(echo "$line" | grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z\]' | tr -d '[]')

        # Read next 2 lines to get temp and location
        read -r temp_line
        echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $temp_line"
        read -r loc_line
        echo -e "${COLOR_PREFIX}[${SUB_NAME}]${COLOR_RESET} $loc_line"

        # Extract temperature value
        TEMP=$(echo "$temp_line" | grep -oE '[0-9]+\.[0-9]+')

        # Extract location value
        LOCATION=$(echo "$loc_line" | sed -n 's/.*Location: \([a-zA-Z0-9_-]*\).*/\1/p')

        # Try to extract publisher from location if it contains it
        # Publishers will format location as "test-lab-publisher-<name>"
        if echo "$LOCATION" | grep -q "test-lab-publisher-"; then
            PUBLISHER=$(echo "$LOCATION" | sed 's/test-lab-publisher-//')
        else
            PUBLISHER="unknown"
        fi

        # Emit structured log line for test script to parse
        echo "RECEIVED|${SUB_NAME}|${PUBLISHER}|${TIMESTAMP}|temp=${TEMP},location=${LOCATION}"
    fi
done
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/wrappers/wrap-subscriber.sh`

**Step 3: Test wrapper with one subscriber**

Run: `/Users/ivan/Projects/mqtt-getting-started/client/wrappers/wrap-subscriber.sh nodejs mqtt 34`
Expected: See `[nodejs-mqtt]` prefix in blue color on output, subscriber connects and waits for messages

**Step 4: Commit**

```bash
git add client/wrappers/wrap-subscriber.sh
git commit -m "feat: add universal subscriber wrapper with structured logging"
```

---

## Task 3: Create Test Publisher Wrapper for Node.js MQTT

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/nodejs/mqtt-publish-test.js`

**Step 1: Write test publisher that accepts JSON argument**

This publisher accepts a JSON payload as command-line argument:

```javascript
const mqtt = require('mqtt');

// Get payload from command line argument
if (process.argv.length < 3) {
  console.error('Usage: node mqtt-publish-test.js \'{"temp":72.5,"location":"test-lab"}\'');
  process.exit(1);
}

const payloadData = JSON.parse(process.argv[2]);
const client = mqtt.connect('mqtt://localhost:1883');

client.on('connect', () => {
  console.log('Connected to MQTT broker');

  const topic = 'Sensors/101';
  const payload = JSON.stringify(payloadData);

  client.publish(topic, payload, { retain: true, qos: 1 }, (err) => {
    if (err) {
      console.error('Publish error:', err);
      process.exit(1);
    } else {
      console.log(`Published: ${payload}`);
      client.end();
    }
  });
});

client.on('error', (err) => {
  console.error('Connection error:', err);
  client.end();
  process.exit(1);
});
```

**Step 2: Test the publisher**

Run: `node /Users/ivan/Projects/mqtt-getting-started/client/nodejs/mqtt-publish-test.js '{"temp":72.5,"location":"test-lab","publisher":"test"}'`
Expected: Connects, publishes message, exits cleanly

**Step 3: Commit**

```bash
git add client/nodejs/mqtt-publish-test.js
git commit -m "feat: add MQTT test publisher accepting JSON payload"
```

---

## Task 4: Create Test Publisher Wrapper for Node.js WebSocket

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/nodejs/ws-publish-test.js`

**Step 1: Write test publisher that accepts JSON argument**

```javascript
const WebSocket = require('ws');

// Get payload from command line argument
if (process.argv.length < 3) {
  console.error('Usage: node ws-publish-test.js \'{"temp":72.5,"location":"test-lab"}\'');
  process.exit(1);
}

const payloadData = JSON.parse(process.argv[2]);
const ws = new WebSocket('ws://localhost:9926/Sensors/101');

ws.on('open', () => {
  console.log('Connected to Harper WebSocket');

  // WebSocket expects array format
  const payload = JSON.stringify([payloadData]);

  ws.send(payload, (err) => {
    if (err) {
      console.error('Error sending message:', err);
      process.exit(1);
    } else {
      console.log(`Published: ${payload}`);
      ws.close();
    }
  });
});

ws.on('error', (err) => {
  console.error('WebSocket error:', err.message);
  process.exit(1);
});

ws.on('close', () => {
  process.exit(0);
});
```

**Step 2: Test the publisher**

Run: `node /Users/ivan/Projects/mqtt-getting-started/client/nodejs/ws-publish-test.js '{"temp":73.2,"location":"test-lab","publisher":"test"}'`
Expected: Connects, publishes message, exits cleanly

**Step 3: Commit**

```bash
git add client/nodejs/ws-publish-test.js
git commit -m "feat: add WebSocket test publisher accepting JSON payload"
```

---

## Task 5: Create Test Publisher Wrapper for Python MQTT

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/python/mqtt-publish-test.py`

**Step 1: Write test publisher that accepts JSON argument**

```python
#!/usr/bin/env python3
"""
MQTT Test Publisher - accepts JSON payload as command-line argument
Usage: python3 mqtt-publish-test.py '{"temp":72.5,"location":"test-lab"}'
"""

import sys
import json
import paho.mqtt.client as mqtt

if len(sys.argv) < 2:
    print('Usage: python3 mqtt-publish-test.py \'{"temp":72.5,"location":"test-lab"}\'')
    sys.exit(1)

# Parse payload from command line
payload_data = json.loads(sys.argv[1])

def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to broker"""
    if reason_code == 0:
        print("Connected to MQTT broker")

        topic = "Sensors/101"
        payload = json.dumps(payload_data)

        result = client.publish(topic, payload, qos=1, retain=True)

        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"Published: {payload}")
        else:
            print(f"Publish failed with code {result.rc}")
            sys.exit(1)

        client.disconnect()
    else:
        print(f"Connection failed with code {reason_code}")
        sys.exit(1)

def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_forever()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/python/mqtt-publish-test.py`

**Step 3: Test the publisher**

Run: `python3 /Users/ivan/Projects/mqtt-getting-started/client/python/mqtt-publish-test.py '{"temp":71.8,"location":"test-lab","publisher":"test"}'`
Expected: Connects, publishes message, exits cleanly

**Step 4: Commit**

```bash
git add client/python/mqtt-publish-test.py
git commit -m "feat: add Python MQTT test publisher accepting JSON payload"
```

---

## Task 6: Create Test Publisher Wrapper for Python WebSocket

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/python/ws-publish-test.py`

**Step 1: Write test publisher that accepts JSON argument**

```python
#!/usr/bin/env python3
"""
WebSocket Test Publisher - accepts JSON payload as command-line argument
Usage: python3 ws-publish-test.py '{"temp":72.5,"location":"test-lab"}'
"""

import sys
import json
import asyncio
import websockets

if len(sys.argv) < 2:
    print('Usage: python3 ws-publish-test.py \'{"temp":72.5,"location":"test-lab"}\'')
    sys.exit(1)

# Parse payload from command line
payload_data = json.loads(sys.argv[1])

async def publish():
    """Publish a single message via WebSocket"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")

            # WebSocket expects array format (matching ws-publish.js behavior)
            payload = json.dumps([payload_data])

            await websocket.send(payload)
            print(f"Published: {payload}")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def main():
    asyncio.run(publish())

if __name__ == "__main__":
    main()
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/python/ws-publish-test.py`

**Step 3: Test the publisher**

Run: `python3 /Users/ivan/Projects/mqtt-getting-started/client/python/ws-publish-test.py '{"temp":74.1,"location":"test-lab","publisher":"test"}'`
Expected: Connects, publishes message, exits cleanly

**Step 4: Commit**

```bash
git add client/python/ws-publish-test.py
git commit -m "feat: add Python WebSocket test publisher accepting JSON payload"
```

---

## Task 7: Create run-all-subscribers.sh Script

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/run-all-subscribers.sh`

**Step 1: Write the subscriber orchestration script**

```bash
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
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/run-all-subscribers.sh`

**Step 3: Test dependency checks**

Run: `/Users/ivan/Projects/mqtt-getting-started/client/run-all-subscribers.sh`
Expected: Script checks for tmux, Harper, MQTT broker (may warn if services not running)

**Step 4: Commit**

```bash
git add client/run-all-subscribers.sh
git commit -m "feat: add subscriber orchestration with tmux grid layout"
```

---

## Task 8: Create run-publishers.sh Test Script

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/run-publishers.sh`

**Step 1: Write the publisher test orchestration script**

```bash
#!/usr/bin/env bash
# Run each publisher and verify all subscribers received the message

set -euo pipefail

SESSION_NAME="mqtt-test-subscribers"
TIMEOUT=5
PROJECT_ROOT="/Users/ivan/Projects/mqtt-getting-started"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
declare -A RESULTS

echo "========================================="
echo "Cross-Protocol Pub/Sub Test Suite"
echo "========================================="
echo ""

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${RED}Error: Subscriber session not found${NC}"
    echo "Start subscribers first: ./run-all-subscribers.sh"
    exit 1
fi

echo "Found subscriber session: $SESSION_NAME"
echo "Timeout per test: ${TIMEOUT}s"
echo ""

# Function to run a publisher test
run_publisher_test() {
    local lang="$1"
    local protocol="$2"
    local pub_name="${lang}-${protocol}"

    echo "========================================="
    echo -e "${BLUE}Testing: ${pub_name}${NC}"
    echo "========================================="

    # Generate unique message payload
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp=$(awk -v min=68 -v max=75 'BEGIN{srand(); print min+rand()*(max-min)}')
    local location="test-lab-publisher-${pub_name}"
    local payload="{\"temp\":${temp},\"location\":\"${location}\",\"publisher\":\"${pub_name}\",\"timestamp\":\"${timestamp}\"}"

    echo "Payload: $payload"
    echo ""

    # Determine which test publisher to use
    if [ "$lang" = "nodejs" ]; then
        local cmd="node ${PROJECT_ROOT}/client/nodejs/${protocol}-publish-test.js"
    else
        local cmd="python3 ${PROJECT_ROOT}/client/python/${protocol}-publish-test.py"
    fi

    # Publish the message
    echo "Publishing..."
    if ! $cmd "$payload" 2>&1; then
        echo -e "${RED}✗ Publish failed${NC}"
        RESULTS["$pub_name"]="FAIL|0|6|Publish error"
        return 1
    fi

    echo ""
    echo "Waiting ${TIMEOUT}s for message propagation..."
    sleep "$TIMEOUT"

    # Capture all tmux panes and look for RECEIVED lines
    echo "Checking subscriber receipts..."
    local received_count=0
    local missing_subs=()

    # Check each of the 6 panes
    for pane_id in 0 1 2 3 4 5; do
        local pane_content=$(tmux capture-pane -t "${SESSION_NAME}:0.${pane_id}" -p)

        # Look for RECEIVED line matching our publisher
        if echo "$pane_content" | tail -20 | grep -q "RECEIVED|.*|${pub_name}|"; then
            ((received_count++))
        else
            # Determine which subscriber this pane is
            case $pane_id in
                0) missing_subs+=("nodejs-mqtt") ;;
                1) missing_subs+=("nodejs-ws") ;;
                2) missing_subs+=("nodejs-sse") ;;
                3) missing_subs+=("python-mqtt") ;;
                4) missing_subs+=("python-ws") ;;
                5) missing_subs+=("python-sse") ;;
            esac
        fi
    done

    # Report results
    echo ""
    if [ "$received_count" -eq 6 ]; then
        echo -e "${GREEN}✓ SUCCESS: All 6 subscribers received message${NC}"
        RESULTS["$pub_name"]="PASS|6|6|"
    else
        echo -e "${RED}✗ FAILED: Only ${received_count}/6 subscribers received message${NC}"
        echo -e "${YELLOW}Missing: ${missing_subs[*]}${NC}"
        RESULTS["$pub_name"]="FAIL|${received_count}|6|Missing: ${missing_subs[*]}"
    fi
    echo ""
}

# Run all publisher tests
run_publisher_test "nodejs" "mqtt"
run_publisher_test "nodejs" "ws"
run_publisher_test "python" "mqtt"
run_publisher_test "python" "ws"

# Print final summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo ""

total_tests=0
passed_tests=0

for pub_name in "nodejs-mqtt" "nodejs-ws" "python-mqtt" "python-ws"; do
    ((total_tests++))
    IFS='|' read -r status received total details <<< "${RESULTS[$pub_name]}"

    if [ "$status" = "PASS" ]; then
        ((passed_tests++))
        echo -e "${GREEN}✓${NC} ${pub_name}: ${received}/${total} subscribers"
    else
        echo -e "${RED}✗${NC} ${pub_name}: ${received}/${total} subscribers ($details)"
    fi
done

echo ""
echo "Overall: ${passed_tests}/${total_tests} publishers fully successful"
echo ""

if [ "$passed_tests" -eq "$total_tests" ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some tests failed${NC}"
    exit 1
fi
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/run-publishers.sh`

**Step 3: Verify script checks for dependencies**

Run: `/Users/ivan/Projects/mqtt-getting-started/client/run-publishers.sh`
Expected: Error message about missing subscriber session (since we haven't started subscribers)

**Step 4: Commit**

```bash
git add client/run-publishers.sh
git commit -m "feat: add publisher test orchestration with automated verification"
```

---

## Task 9: Create Master test.sh Script

**Files:**
- Create: `/Users/ivan/Projects/mqtt-getting-started/client/test.sh`

**Step 1: Write the all-in-one test script**

```bash
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
```

**Step 2: Make script executable**

Run: `chmod +x /Users/ivan/Projects/mqtt-getting-started/client/test.sh`

**Step 3: Verify script structure**

Run: `head -20 /Users/ivan/Projects/mqtt-getting-started/client/test.sh`
Expected: See proper shebang, color codes, and initial checks

**Step 4: Commit**

```bash
git add client/test.sh
git commit -m "feat: add master test script for all-in-one execution"
```

---

## Task 10: Update README with Test Documentation

**Files:**
- Modify: `/Users/ivan/Projects/mqtt-getting-started/README.md`

**Step 1: Add testing section to README**

Add the following section after the existing content:

```markdown

## Testing

### Cross-Protocol Test Suite

Automated tests verify that messages published via any protocol (MQTT/WebSocket) are received by all subscribers across all protocols and languages.

#### Quick Start

Run all tests with one command:

```bash
cd client
./test.sh
```

This will:
1. Launch all 6 subscribers in a tmux session (2x3 grid)
2. Test each of the 4 publishers sequentially
3. Verify all subscribers receive each message
4. Display a summary report

#### Individual Scripts

You can also run components separately:

**Start subscribers:**
```bash
./run-all-subscribers.sh
```

View the tmux session:
```bash
tmux attach -t mqtt-test-subscribers
```

Detach: `Ctrl+b` then `d`

**Run publisher tests:**
```bash
./run-publishers.sh
```

**Stop subscribers:**
```bash
./run-all-subscribers.sh stop
```

#### Test Architecture

- **6 Subscribers**: nodejs-mqtt, nodejs-ws, nodejs-sse, python-mqtt, python-ws, python-sse
- **4 Publishers**: nodejs-mqtt, nodejs-ws, python-mqtt, python-ws
- **Cross-protocol verification**: Each publisher's message must reach all 6 subscribers
- **Visual monitoring**: tmux grid shows real-time output from all subscribers
- **Automated verification**: Test script parses subscriber output and reports pass/fail

#### Requirements

- tmux (install: `brew install tmux` on macOS)
- Harper running on localhost:9926
- MQTT broker running on localhost:1883
```

**Step 2: Verify README is valid markdown**

Run: `grep -A 5 "## Testing" /Users/ivan/Projects/mqtt-getting-started/README.md`
Expected: See the new testing section

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add cross-protocol test suite documentation"
```

---

## Task 11: End-to-End Test

**Files:**
- All created scripts

**Step 1: Ensure Harper is running**

Run: `ps aux | grep -i harper | grep -v grep`
Expected: See Harper process running, or start it with `cd harper && npm start` in a separate terminal

**Step 2: Ensure MQTT broker is running**

Run: `ps aux | grep -i mqtt | grep -v grep`
Expected: See MQTT broker process (mosquitto or similar)

**Step 3: Run the full test suite**

Run: `cd /Users/ivan/Projects/mqtt-getting-started/client && ./test.sh`

Expected output:
- Subscribers start in tmux
- Each of 4 publishers tested sequentially
- Summary shows "4/4 publishers fully successful" or details of failures
- All tests should pass if Harper and MQTT broker are properly configured

**Step 4: Manually verify tmux layout**

While test is running, in another terminal:
Run: `tmux attach -t mqtt-test-subscribers`

Expected: See 2x3 grid with 6 color-coded subscriber panes, each showing connection status and message receipts

Press `Ctrl+b` then `d` to detach

**Step 5: Review test output**

Expected:
- Each publisher shows "✓ SUCCESS: All 6 subscribers received message"
- Final summary: "All tests passed!"
- Exit code 0

**Step 6: Clean up**

Run: `/Users/ivan/Projects/mqtt-getting-started/client/run-all-subscribers.sh stop`
Expected: "No session to stop" or successful cleanup message

**Step 7: Commit any fixes**

If any issues found during testing, fix them and commit:
```bash
git add <fixed-files>
git commit -m "fix: <description of fix>"
```

---

## Completion Checklist

- [ ] All 4 test publisher scripts created and working
- [ ] Universal subscriber wrapper created
- [ ] run-all-subscribers.sh launches 6 subscribers in tmux grid
- [ ] run-publishers.sh tests all 4 publishers with verification
- [ ] test.sh orchestrates full test suite
- [ ] README updated with test documentation
- [ ] End-to-end test passes successfully
- [ ] All changes committed to git

## Verification Commands

Test individual components:
```bash
# Test wrapper
./client/wrappers/wrap-subscriber.sh nodejs mqtt 34

# Test publisher
node ./client/nodejs/mqtt-publish-test.js '{"temp":72.5,"location":"test"}'

# Test tmux layout
./client/run-all-subscribers.sh
tmux attach -t mqtt-test-subscribers

# Full test
./client/test.sh
```

## Notes

- Scripts use absolute paths to avoid directory confusion
- ANSI color codes work on most modern terminals
- Tmux session persists until explicitly stopped
- Test publishers use `retain: true` (MQTT) to ensure database persistence
- WebSocket publishers use array format matching Harper expectations
- Parser looks for structured "RECEIVED|" lines in subscriber output
