#!/usr/bin/env python3
"""
MQTT Publisher for sensor data
Requires: pip install paho-mqtt

Usage:
  python3 mqtt-publish.py                                    # Continuous publishing with auto-generated messages
  python3 mqtt-publish.py '{"temp":72.5,"location":"test"}'  # Single publish with custom payload (for testing)
"""

import sys
import os
import json
import random
import time
import paho.mqtt.client as mqtt


def random_temp():
    """Generate random temperature between 65-85°F"""
    return round(random.uniform(65, 85), 4)


# Check retain flag (defaults to true, set MQTT_RETAIN=false for ephemeral messages)
retain = os.environ.get('MQTT_RETAIN', 'true').lower() != 'false'


def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to broker"""
    if reason_code == 0:
        print("Connected to MQTT broker")
    else:
        print(f"Connection failed with code {reason_code}")
        sys.exit(1)


def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_start()

        # Wait for connection
        time.sleep(0.5)

        # Check if custom payload provided (for testing)
        custom_payload = sys.argv[1] if len(sys.argv) >= 2 else None

        if custom_payload:
            # Single publish with provided payload (for testing)
            result = client.publish("Sensors/101", custom_payload, qos=1, retain=retain)
            result.wait_for_publish()
            print(f"Published: {custom_payload} (retain: {retain})")
            client.loop_stop()
            client.disconnect()
        else:
            # Default: continuous publishing with auto-generated messages
            print(f"Publishing every 5 seconds (retain: {retain})... (Ctrl+C to stop)\n")

            while True:
                payload = json.dumps({
                    "temp": random_temp(),
                    "location": "warehouse"
                })

                client.publish("Sensors/101", payload, qos=1, retain=retain)
                print(f"Published: {payload}")

                time.sleep(5)

    except KeyboardInterrupt:
        print("\nStopping publisher...")
        client.loop_stop()
        client.disconnect()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
