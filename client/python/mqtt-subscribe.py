#!/usr/bin/env python3
"""
MQTT Subscriber for sensor data
Requires: pip install paho-mqtt
"""

import json
from datetime import datetime
import paho.mqtt.client as mqtt


def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to broker"""
    if reason_code == 0:
        print("Connected to MQTT broker")

        # Subscribe to sensor 101 topic:
        topic = "Sensors/101"
        # Subscribe to all sensor topics (Sensors/101, Sensors/102, etc.)
        # topic = "Sensors/#"

        client.subscribe(topic)
        print(f"Subscribed to: {topic}")
        print("Listening for messages...\n")
    else:
        print(f"Connection failed with code {reason_code}")


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


def on_disconnect(client, userdata, disconnect_flags, reason_code, properties):
    """Callback when disconnected from broker"""
    if reason_code != 0:
        print(f"Unexpected disconnection. Code: {reason_code}")


def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
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
