# Harper Real-Time Messaging Getting Started

A complete real-time messaging starter project featuring a Harper application with MQTT, WebSocket, and Server-Sent Events (SSE) capabilities, plus client examples in multiple languages.

## Overview

This repository provides everything you need to get started with real-time messaging using Harper:

- **Harper Application** - A Harper application with built-in MQTT broker and real-time capabilities
- **Client Examples** - Publisher and subscriber implementations using MQTT, WebSocket, and SSE in Node.js, Python, and MQTTX CLI

## Quick Start

### 1. Set Up Environment

This project uses pyenv for Python environment management. Run the setup script to configure everything:

```bash
./setup.sh
```

Or manually:

```bash
# Create and activate Python environment
pyenv virtualenv 3.11 mqtt-getting-started
pyenv local mqtt-getting-started

# Install dependencies
pip install -r requirements.txt
cd harper && npm install
cd client/nodejs && npm install
```

### 2. Start the Harper Application

Set up and run the Harper application:

```bash
cd harper
npm install
npm run dev
```

See the [harper/README.md](./harper/README.md) for detailed setup and configuration.

### 3. Run a Client

Once the Harper application is running, choose your preferred client implementation:

```bash
# Node.js
cd client/nodejs && npm install

# Python (environment already activated via .python-version)
cd client/python

# MQTTX CLI
cd client/mqttx && ./install.sh
```

Each client directory contains its own README with specific instructions.

## Project Structure

```
harper-mqtt-getting-started/
├── harper/                  # Harper application with real-time capabilities
│   ├── config.yaml          # Application configuration
│   ├── schema.graphql       # Database schema
│   ├── resources.js         # Application logic
│   └── package.json
└── client/                  # Real-time client examples
    ├── nodejs/              # Node.js clients (MQTT, WebSocket, SSE)
    │   ├── mqtt-publish.js
    │   ├── mqtt-subscribe.js
    │   ├── ws-publish.js
    │   ├── ws-subscribe.js
    │   ├── sse-subscribe.js
    │   └── package.json
    ├── python/              # Python clients (MQTT, WebSocket, SSE)
    │   ├── mqtt-publish.py
    │   ├── mqtt-subscribe.py
    │   ├── ws-publish.py
    │   ├── ws-subscribe.py
    │   ├── sse-subscribe.py
    │   └── requirements.txt
    └── mqttx/               # MQTTX CLI shell scripts
        ├── mqttx_publish.sh
        ├── mqttx_subscribe.sh
        └── install.sh
```

## Client Implementations

### [Node.js](./client/nodejs/)
Real-time clients supporting MQTT, WebSocket, and SSE.
- **MQTT:** Full pub/sub broker with topic-based routing using `mqtt` package
- **WebSocket:** Bidirectional communication using `ws` package
- **SSE:** Server-to-client streaming using `eventsource` package
- Supports modern async/await patterns
- Easy to integrate into existing Node.js projects

### [Python](./client/python/)
Real-time clients supporting MQTT, WebSocket, and SSE.
- **MQTT:** Industry-standard `paho-mqtt` library
- **WebSocket:** Async support with `websockets` library
- **SSE:** Server-to-client streaming using `sseclient-py` library
- Clean and readable Python code
- Great for IoT and data processing applications

### [MQTTX CLI](./client/mqttx/)
Shell script examples using the MQTTX command-line tool.
- No programming required
- Quick testing and debugging
- Platform-agnostic command-line interface


## Protocol Comparison

- **MQTT:** Full pub/sub broker, topic-based routing, QoS levels, requires retain flag for persistence
- **WebSocket:** Bidirectional communication, direct resource connection, automatic persistence, lower overhead
- **SSE:** Unidirectional (server→client), simple HTTP-based, automatic reconnection, automatic persistence

## Publisher Usage

All publishers support two modes of operation:

### Default Mode: Continuous Publishing
Run without arguments to continuously publish auto-generated messages every 5 seconds:

```bash
# Node.js
node client/nodejs/mqtt-publish.js
node client/nodejs/ws-publish.js

# Python
python3 client/python/mqtt-publish.py
python3 client/python/ws-publish.py

# MQTTX CLI
client/mqttx/mqttx-publish.sh
```

### Test Mode: Single Custom Message
Provide a JSON payload as an argument for testing (used by test suite):

```bash
# Node.js
node client/nodejs/mqtt-publish.js '{"temp":72.5,"location":"test-lab"}'

# Python
python3 client/python/mqtt-publish.py '{"temp":72.5,"location":"test-lab"}'

# MQTTX CLI
client/mqttx/mqttx-publish.sh '{"temp":72.5,"location":"test-lab"}'
```

### Message Persistence (MQTT Only)

MQTT messages support persistence control via the `MQTT_RETAIN` environment variable:

- **`MQTT_RETAIN=true` (default):** Messages are retained and stored in the database
- **`MQTT_RETAIN=false`:** Messages are ephemeral, forwarded to active subscribers only, not stored

```bash
# Persistent message (stored in database)
node client/nodejs/mqtt-publish.js '{"temp":72.5,"location":"warehouse"}'

# Ephemeral message (not stored, only forwarded to active subscribers)
MQTT_RETAIN=false node client/nodejs/mqtt-publish.js '{"temp":72.5,"location":"warehouse"}'

# Also works in continuous mode
MQTT_RETAIN=false python3 client/python/mqtt-publish.py
```

**Note:** WebSocket messages to Harper resources are always persisted automatically.

## Testing

### Cross-Protocol Test Suite

Automated tests verify that messages published via any protocol (MQTT/WebSocket) are received by all subscribers across all protocols and languages.

### Test Results

<!-- TEST_RESULTS_START -->

Last run: 2026-01-05 16:27:48 UTC

| Publisher (rows) / Subscriber (columns) | nodejs-mqtt | nodejs-ws | nodejs-sse | python-mqtt | python-ws | python-sse | mqttx-mqtt |
|----------------------------------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|
| Node.js MQTT | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Node.js WS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Python MQTT | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Python WS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| MQTTX MQTT | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

<!-- TEST_RESULTS_END -->

#### Quick Start

Run all tests with one command:

```bash
cd client
./test.sh
```

This will:
1. Launch all 7 subscribers in background
2. Test each of the 5 publishers sequentially
3. Verify all subscribers receive each message
4. Display a summary report

#### Individual Scripts

You can also run components separately:

**Start subscribers:**
```bash
./run-all-subscribers.sh
```

**View subscriber logs:**
```bash
tail -f ../test-logs/*.log
```

**Run publisher tests:**
```bash
./run-publishers.sh
```

**Stop subscribers:**
```bash
./run-all-subscribers.sh stop
```

#### Test Architecture

- **7 Subscribers**: nodejs-mqtt, nodejs-ws, nodejs-sse, python-mqtt, python-ws, python-sse, mqttx-mqtt
- **5 Publishers**: nodejs-mqtt, nodejs-ws, python-mqtt, python-ws, mqttx-mqtt
- **Cross-protocol verification**: Each publisher's message must reach all 7 subscribers
- **Log-based monitoring**: Subscribers write to log files in `test-logs/`
- **Automated verification**: Test script parses subscriber logs and reports pass/fail

#### Requirements

- Harper running on localhost:9926
- MQTT broker running on localhost:1883
- mqttx-cli (install: `npm install -g @emqx/mqttx-cli` or `brew install emqx/mqttx/mqttx-cli`)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
