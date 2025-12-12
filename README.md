# Harper MQTT Getting Started

A complete MQTT messaging starter project featuring a Harper application with MQTT capabilities and client examples in multiple languages.

## Overview

This repository provides everything you need to get started with MQTT messaging using Harper:

- **Harper Application** - A Harper application with built-in MQTT broker capabilities
- **Client Examples** - Publisher and subscriber implementations in Node.js, Python, and MQTTX CLI

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
├── harper/              # Harper application with MQTT broker
│   ├── config.yaml      # Application configuration
│   ├── schema.graphql   # Database schema
│   ├── resources.js     # Application logic
│   └── package.json
└── client/              # MQTT client examples
    ├── nodejs/          # Node.js MQTT examples
    │   ├── publisher.js
    │   ├── subscriber.js
    │   └── package.json
    ├── python/          # Python MQTT examples
    │   ├── publisher.py
    │   ├── subscriber.py
    │   └── requirements.txt
    └── mqttx/           # MQTTX CLI shell scripts
        ├── mqttx_publish.sh
        ├── mqttx_subscribe.sh
        └── install.sh
```

## Client Implementations

### [Node.js](./client/nodejs/)
JavaScript MQTT clients using the `mqtt` npm package.
- Simple and widely-used MQTT library
- Supports modern async/await patterns
- Easy to integrate into existing Node.js projects

### [Python](./client/python/)
Python MQTT clients using the `paho-mqtt` library.
- Industry-standard MQTT client library
- Clean and readable Python code
- Great for IoT and data processing applications

### [MQTTX CLI](./client/mqttx/)
Shell script examples using the MQTTX command-line tool.
- No programming required
- Quick testing and debugging
- Platform-agnostic command-line interface

## Tier Structure

All client implementations follow the same tier progression:

- **Tier 0 (MVP):** Single message publish, no database persistence
- **Tier 1:** Enable database persistence with retain flag
- **Tier 2:** Continuous publishing every 5 seconds

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
