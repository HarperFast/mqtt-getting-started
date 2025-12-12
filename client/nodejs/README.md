# Node.js MQTT Clients

MQTT publisher and subscriber implemented in Node.js.

## Dependencies

- **Node.js** v14+
- **mqtt** package (v5.14.1)

## Installation

```bash
npm install
```

## Usage

### Publisher
```bash
node publisher.js
```

### Subscriber
```bash
node subscriber.js
```

## Tier Structure

- **Tier 0 (MVP):** Single publish, no database persistence (`retain: false`)
- **Tier 1:** Enable database persistence (`retain: true`)
- **Tier 2:** Continuous publishing every 5 seconds
