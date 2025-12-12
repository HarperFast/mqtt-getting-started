#!/usr/bin/env python3
"""
MQTT Subscriber for sensor data
Requires: pip install paho-mqtt
"""

import json
from datetime import datetime
import paho.mqtt.client as mqtt


def on_connect(client, userdata, flags, rc):
    """Callback when connected to broker"""
    if rc == 0:
        print("Connected to MQTT broker")

        # Subscribe to sensor 101 topic:
        topic = "sensors/101"
        # Subscribe to all sensor topics (sensors/101, sensors/102, etc.)
        # topic = "sensors/#"

        client.subscribe(topic)
        print(f"Subscribed to: {topic}")
        print("Listening for messages...\n")
    else:
        print(f"Connection failed with code {rc}")


def on_message(client, userdata, msg):
    """Callback when message is received"""
    # Receives the stored state immediately (retained messages),
    # then real-time updates as they're published
    try:
        payload = json.loads(msg.payload.decode())
        timestamp = datetime.now().isoformat()

        print(f"[{timestamp}] Update on {msg.topic}:")
        print(f"  Temperature: {payload['temp']}°F")
        print(f"  Location: {payload['location']}")
        print()

    except json.JSONDecodeError:
        # If message isn't JSON, just log it as-is
        timestamp = datetime.now().isoformat()
        print(f"[{timestamp}] Update on {msg.topic}: {msg.payload.decode()}")
        print()
    except Exception as e:
        print(f"Error processing message: {e}")
        print()


def on_disconnect(client, userdata, rc):
    """Callback when disconnected from broker"""
    if rc != 0:
        print(f"Unexpected disconnection. Code: {rc}")


def main():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        print("\nStopping subscriber...")
        client.disconnect()
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
