# Harper Real-Time Messaging Getting Started

A complete real-time messaging starter project featuring a Harper application with MQTT, WebSocket, and Server-Sent Events (SSE) capabilities, plus client examples in multiple languages.

## Overview

This repository provides everything you need to get started with real-time messaging using Harper:

- **Harper Application** - A Harper application with built-in MQTT broker and real-time capabilities
- **Client Examples** - Publisher and subscriber implementations using MQTT, WebSocket, and SSE in Node.js, Python, and MQTTX CLI

## Quick Start

### 1. Start the Harper Application

First, set up and run the Harper application:

```bash
cd harper
npm install
npm run dev
```

See the [harper/README.md](./harper/README.md) for detailed setup and configuration.

### 2. Run a Client

Once the Harper application is running, choose your preferred client implementation:

```bash
# Node.js
cd client/nodejs && npm install

# Python
cd client/python && pip install -r requirements.txt

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

## Tier Structure

All client implementations follow the same tier progression:

- **Tier 0 (MVP):** Single message publish (MQTT: no persistence, WebSocket/SSE: automatic persistence)
- **Tier 1:** Enable database persistence (MQTT: `retain` flag, WebSocket/SSE: automatic)
- **Tier 2:** Continuous publishing every 5 seconds

## Protocol Comparison

- **MQTT:** Full pub/sub broker, topic-based routing, QoS levels, requires retain flag for persistence
- **WebSocket:** Bidirectional communication, direct resource connection, automatic persistence, lower overhead
- **SSE:** Unidirectional (server→client), simple HTTP-based, automatic reconnection, automatic persistence

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
1. Launch all 6 subscribers in background
2. Test each of the 4 publishers sequentially
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

- **6 Subscribers**: nodejs-mqtt, nodejs-ws, nodejs-sse, python-mqtt, python-ws, python-sse
- **4 Publishers**: nodejs-mqtt, nodejs-ws, python-mqtt, python-ws
- **Cross-protocol verification**: Each publisher's message must reach all 6 subscribers
- **Log-based monitoring**: Subscribers write to log files in `test-logs/`
- **Automated verification**: Test script parses subscriber logs and reports pass/fail

#### Requirements

- Harper running on localhost:9926
- MQTT broker running on localhost:1883

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
