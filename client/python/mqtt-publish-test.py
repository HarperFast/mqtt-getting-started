#!/usr/bin/env python3
"""
MQTT Test Publisher - accepts JSON payload as command-line argument
Usage: python3 mqtt-publish-test.py '{"temp":72.5,"location":"test-lab"}'
"""

import sys
import json
import paho.mqtt.client as mqtt

if len(sys.argv) < 2:
    print('Usage: python3 mqtt-publish-test.py \'{"temp":72.5,"location":"test-lab"}\'')
    sys.exit(1)

# Parse payload from command line
payload_data = json.loads(sys.argv[1])

def on_connect(client, userdata, flags, reason_code, properties):
    """Callback when connected to broker"""
    if reason_code == 0:
        print("Connected to MQTT broker")

        topic = "Sensors/101"
        payload = json.dumps(payload_data)

        result = client.publish(topic, payload, qos=1, retain=True)

        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"Published: {payload}")
        else:
            print(f"Publish failed with code {result.rc}")
            sys.exit(1)

        client.disconnect()
    else:
        print(f"Connection failed with code {reason_code}")
        sys.exit(1)

def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect

    try:
        client.connect("localhost", 1883, 60)
        client.loop_forever()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
