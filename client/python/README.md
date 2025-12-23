# Python Real-Time Clients

Real-time publisher and subscriber clients for Harper using MQTT, WebSocket, and Server-Sent Events (SSE).

## Dependencies

- **Python** 3.7+
- **paho-mqtt** package (v2.0.0+) - for MQTT clients
- **websockets** package (v12.0+) - for WebSocket clients
- **sseclient-py** package (v1.8.0+) - for SSE clients
- **requests** package (v2.31.0+) - for SSE clients

## Installation

```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install paho-mqtt websockets sseclient-py requests
```

## Usage

### MQTT Clients

#### Publisher
```bash
./mqtt-publish.py
# or
python3 mqtt-publish.py
```

#### Subscriber
```bash
./mqtt-subscribe.py
# or
python3 mqtt-subscribe.py
```

### WebSocket Clients

#### Publisher
```bash
./ws-publish.py
# or
python3 ws-publish.py
```

#### Subscriber
```bash
./ws-subscribe.py
# or
python3 ws-subscribe.py
```

### SSE (Server-Sent Events) Client

#### Subscriber
```bash
./sse-subscribe.py
# or
python3 sse-subscribe.py
```

**Note:** SSE is unidirectional (server to client only), so there is no SSE publisher.

## Tier Structure

All clients follow the same tier progression:

- **Tier 0 (MVP):** Single publish, automatic database persistence for WebSocket/SSE
- **Tier 1:** Database persistence enabled (MQTT: `retain=True`)
- **Tier 2:** Continuous publishing every 5 seconds

## Protocol Comparison

- **MQTT:** Full pub/sub broker, topic-based routing, QoS levels
- **WebSocket:** Bidirectional, direct resource connection, lower overhead
- **SSE:** Unidirectional (server→client), simple HTTP-based, automatic reconnection
