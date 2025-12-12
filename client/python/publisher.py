#!/usr/bin/env python3
"""
MQTT Publisher for sensor data
Requires: pip install paho-mqtt
"""

import json
import random
import time
import paho.mqtt.client as mqtt


def random_temp():
    """Generate random temperature between 65-85°F"""
    return round(random.uniform(65, 85), 1)


def on_connect(client, userdata, flags, rc):
    """Callback when connected to broker"""
    if rc == 0:
        print("Connected to MQTT broker")
        publish_message(client)
    else:
        print(f"Connection failed with code {rc}")


def publish_message(client):
    """Publish a single message"""
    topic = "sensors/101"
    payload = json.dumps({
        "temp": random_temp(),
        "location": "warehouse"
    })

    # ============================================================
    # TIER 0: MVP - Single publish, no database persistence
    # ============================================================
    result = client.publish(topic, payload, qos=1, retain=False)

    if result.rc == mqtt.MQTT_ERR_SUCCESS:
        print(f"Published: {payload}")
    else:
        print(f"Publish failed with code {result.rc}")

    # Disconnect after publishing
    client.disconnect()


def main():
    client = mqtt.Client()
    client.on_connect = on_connect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_forever()
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()


# ============================================================
# TIER 1: Enable database persistence - uncomment to enable
# Change retain=False to retain=True above
# ============================================================

# ============================================================
# TIER 2: Continuous publishing - uncomment to enable
# Replace the main() function above with this version
# ============================================================
"""
def main():
    client = mqtt.Client()

    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT broker")
            print("Publishing every 5 seconds... (Ctrl+C to stop)")
        else:
            print(f"Connection failed with code {rc}")

    client.on_connect = on_connect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_start()

        while True:
            topic = "sensors/101"
            payload = json.dumps({
                "temp": random_temp(),
                "location": "warehouse"
            })

            # Retain = true means "Upsert this record to the database"
            result = client.publish(topic, payload, qos=1, retain=True)

            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"Published: {payload}")
            else:
                print(f"Publish failed with code {result.rc}")

            time.sleep(5)

    except KeyboardInterrupt:
        print("\nStopping publisher...")
        client.loop_stop()
        client.disconnect()
    except Exception as e:
        print(f"Error: {e}")
"""
