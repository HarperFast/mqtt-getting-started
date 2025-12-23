# Cross-Protocol Pub/Sub Test Suite Design

**Date:** 2025-12-23
**Status:** Validated

## Overview

Automated test suite to verify cross-protocol communication in the Harper-based MQTT/WebSocket/SSE pub/sub system. Tests that messages published via any protocol are received by all subscribers across all protocols.

## Requirements

- Test 4 publishers: nodejs-mqtt, nodejs-ws, python-mqtt, python-ws
- Test 6 subscribers: nodejs-mqtt, nodejs-ws, nodejs-sse, python-mqtt, python-ws, python-sse
- Verify cross-protocol communication (e.g., MQTT publish → all 6 subscribers receive)
- Visual monitoring with automated verification
- Continue testing on failures with summary report
- 5-second timeout per message
- Unique messages to trace publisher source

## Architecture

### Three-Script System

1. **`run-all-subscribers.sh`** - Subscriber orchestration
   - Launches 6 subscribers in tmux session (2x3 grid)
   - Each pane runs a wrapper that adds structured output
   - Can run independently for manual testing

2. **`run-publishers.sh`** - Publisher orchestration and verification
   - Publishes from each of 4 publishers sequentially
   - Verifies delivery to all 6 subscribers after each publish
   - Generates summary report of successes/failures
   - Requires subscribers already running

3. **`test.sh`** - Master test script
   - Launches subscribers
   - Waits for connection (3 seconds)
   - Runs publisher tests
   - Optional cleanup

## Component Details

### Subscriber Wrapper (`client/wrappers/wrap-subscriber.sh`)

Universal wrapper script that:
- Takes parameters: language (nodejs/python), protocol (mqtt/ws/sse), color
- Launches appropriate subscriber client
- Adds color-coded prefix: `[nodejs-mqtt]`, `[python-ws]`, etc.
- Detects message receipts and emits structured output:
  ```
  RECEIVED|publisher-id|timestamp|json-data
  ```
- Handles both Node.js and Python output formats

### Tmux Layout

```
┌─────────────────┬─────────────────┬─────────────────┐
│  nodejs-mqtt    │   nodejs-ws     │   nodejs-sse    │
│   (blue)        │   (cyan)        │   (green)       │
├─────────────────┼─────────────────┼─────────────────┤
│  python-mqtt    │   python-ws     │   python-sse    │
│  (yellow)       │   (magenta)     │   (red)         │
└─────────────────┴─────────────────┴─────────────────┘
```

Session name: `mqtt-test-subscribers`

### Publisher Test Flow

For each publisher:

1. **Generate unique message:**
   ```json
   {
     "publisher": "nodejs-mqtt",
     "timestamp": "2025-12-23T10:30:45Z",
     "temp": 72.5,
     "location": "test-lab"
   }
   ```

2. **Publish message** via appropriate client

3. **Wait 5 seconds** for propagation

4. **Capture tmux pane contents** using `tmux capture-pane`

5. **Parse for RECEIVED lines** matching publisher ID and timestamp

6. **Count successes:** Should see 6 RECEIVED lines (one per subscriber)

7. **Record result:**
   - ✓ if 6/6 subscribers received
   - ✗ if < 6, with details of missing subscribers

8. **Continue to next publisher** regardless of result

### Final Report Format

```
Test Results:
  nodejs-mqtt  → 6/6 subscribers ✓
  nodejs-ws    → 6/6 subscribers ✓
  python-mqtt  → 5/6 subscribers ✗ (python-sse timeout)
  python-ws    → 6/6 subscribers ✓

Overall: 3/4 publishers fully successful
```

## Implementation Details

### Message Passing

Publishers will be modified to accept JSON via command-line argument:
```bash
node mqtt-publish.js '{"temp":72.5,"location":"test-lab","publisher":"nodejs-mqtt","timestamp":"..."}'
```

Alternative: Create test-specific publisher wrapper scripts.

### Dependencies

- **tmux** - Terminal multiplexing
- **awk/sed/grep** - Text processing
- **Harper** - Running on localhost:9926
- **MQTT broker** - Running on localhost:1883

Scripts will verify all dependencies before starting.

### Cleanup

- `run-all-subscribers.sh stop` - Kills tmux session
- `test.sh` - Optional cleanup flag

### Color Codes

ANSI escape codes for terminal colors:
- Blue: nodejs-mqtt
- Cyan: nodejs-ws
- Green: nodejs-sse
- Yellow: python-mqtt
- Magenta: python-ws
- Red: python-sse

### Platform Support

Scripts use bash with standard POSIX utilities. Compatible with macOS and Linux.

## Usage

### Independent Operation

```bash
# Terminal 1: Start subscribers
./client/run-all-subscribers.sh

# Terminal 2: Run publisher tests
./client/run-publishers.sh

# Cleanup
./client/run-all-subscribers.sh stop
```

### All-in-One Operation

```bash
./client/test.sh
```

## Success Criteria

- All 4 publishers successfully send messages
- All 6 subscribers receive messages from all 4 publishers
- Test completes in ~25 seconds (4 publishers × 5 seconds + overhead)
- Clear visual feedback during execution
- Detailed summary report at end
- Scripts handle missing dependencies gracefully
