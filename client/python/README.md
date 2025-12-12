# Python MQTT Clients

MQTT publisher and subscriber implemented in Python.

## Dependencies

- **Python** 3.7+
- **paho-mqtt** package (v2.0.0+)

## Installation

```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install paho-mqtt
```

## Usage

### Publisher
```bash
./publisher.py
# or
python3 publisher.py
```

### Subscriber
```bash
./subscriber.py
# or
python3 subscriber.py
```

## Tier Structure

- **Tier 0 (MVP):** Single publish, no database persistence (`retain=False`)
- **Tier 1:** Enable database persistence (`retain=True`)
- **Tier 2:** Continuous publishing every 5 seconds
