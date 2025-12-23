# Node.js Real-Time Clients

Real-time publisher and subscriber clients for Harper using MQTT, WebSocket, and Server-Sent Events (SSE).

## Dependencies

- **Node.js** v14+
- **mqtt** package (v5.14.1) - for MQTT clients
- **ws** package (v8.18.0) - for WebSocket clients
- **eventsource** package (v3.0.2) - for SSE clients

## Installation

```bash
npm install
```

## Usage

### MQTT Clients

#### Publisher
```bash
node mqtt-publish.js
```

#### Subscriber
```bash
node mqtt-subscribe.js
```

### WebSocket Clients

#### Publisher
```bash
node ws-publish.js
```

#### Subscriber
```bash
node ws-subscribe.js
```

### SSE (Server-Sent Events) Client

#### Subscriber
```bash
node sse-subscribe.js
```

**Note:** SSE is unidirectional (server to client only), so there is no SSE publisher.

## Tier Structure

All clients follow the same tier progression:

- **Tier 0 (MVP):** Single publish, automatic database persistence for WebSocket/SSE
- **Tier 1:** Database persistence enabled (MQTT: `retain: true`)
- **Tier 2:** Continuous publishing every 5 seconds

## Protocol Comparison

- **MQTT:** Full pub/sub broker, topic-based routing, QoS levels
- **WebSocket:** Bidirectional, direct resource connection, lower overhead
- **SSE:** Unidirectional (server→client), simple HTTP-based, automatic reconnection
