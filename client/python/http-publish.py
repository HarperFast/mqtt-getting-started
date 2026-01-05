#!/usr/bin/env python3
"""
HTTP Publisher for sensor data (via Harper REST API)
Publishing is done via HTTP PUT to /Sensors/101

Usage:
  python3 http-publish.py                                    # Continuous publishing with auto-generated messages
  python3 http-publish.py '{"temp":72.5,"location":"test"}'  # Single publish with custom payload (for testing)
"""

import sys
import json
import random
import time
import http.client


def random_temp():
    """Generate random temperature between 65-85°F"""
    return round(random.uniform(65, 85), 4)


def http_put(data):
    """Publish a message via HTTP PUT"""
    conn = http.client.HTTPConnection("localhost", 9926)

    try:
        payload = json.dumps(data)
        headers = {
            "Content-Type": "application/json",
            "Content-Length": str(len(payload))
        }

        conn.request("PUT", "/Sensors/101", payload, headers)
        response = conn.getresponse()

        if response.status >= 200 and response.status < 300:
            return True
        else:
            raise Exception(f"HTTP {response.status}: {response.read().decode()}")
    finally:
        conn.close()


def publish_once(payload_data):
    """Publish a single message via HTTP PUT (for testing)"""
    try:
        print("Connected to Harper (HTTP)")
        http_put(payload_data)
        print(f"Published: {json.dumps(payload_data)}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


def publish_continuously():
    """Continuous publishing with auto-generated messages"""
    print("Connected to Harper (HTTP)")
    print("Publishing every 5 seconds... (Ctrl+C to stop)\n")

    try:
        while True:
            data = {
                "temp": random_temp(),
                "location": "warehouse"
            }

            try:
                http_put(data)
                print(f"Published: {json.dumps(data)}")
            except Exception as e:
                print(f"Publish failed: {e}")

            time.sleep(5)

    except KeyboardInterrupt:
        print("\nStopping publisher...")


def main():
    # Check if custom payload provided (for testing)
    custom_payload = sys.argv[1] if len(sys.argv) >= 2 else None

    if custom_payload:
        payload_data = json.loads(custom_payload)
        publish_once(payload_data)
    else:
        publish_continuously()


if __name__ == "__main__":
    main()
