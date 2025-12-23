#!/usr/bin/env python3
"""
Server-Sent Events (SSE) Subscriber for sensor data
Requires: pip install sseclient-py requests
"""

import json
from datetime import datetime
import requests
from sseclient import SSEClient


def subscribe():
    """Subscribe to sensor updates via SSE"""
    url = "http://localhost:9926/Sensors/101"

    try:
        # Create SSE client with streaming request
        # SSE is unidirectional (server to client only)
        response = requests.get(url, stream=True, headers={'Accept': 'text/event-stream'})
        client = SSEClient(response)

        print("Connected to Harper SSE")
        print("Subscribed to: Sensors/101")
        print("Listening for messages...\n")

        # Receives the current state immediately upon connection,
        # then real-time updates as they're published
        for event in client.events():
            try:
                payload = json.loads(event.data)
                # Harper sends change events with metadata, actual data is in 'value'
                record = payload.get('value', payload)
                timestamp = datetime.now().isoformat()

                print(f"[{timestamp}] Update on Sensors/101:")
                print(f"  Temperature: {record['temp']}°F")
                print(f"  Location: {record['location']}")
                print()

            except json.JSONDecodeError:
                # If message isn't JSON, just log it as-is
                timestamp = datetime.now().isoformat()
                print(f"[{timestamp}] Update on Sensors/101: {event.data}")
                print()
            except Exception as e:
                print(f"Error processing message: {e}")
                print()

    except KeyboardInterrupt:
        print("\nStopping subscriber...")
    except Exception as e:
        print(f"Error: {e}")


def main():
    subscribe()


if __name__ == "__main__":
    main()
