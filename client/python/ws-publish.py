#!/usr/bin/env python3
"""
WebSocket Publisher for sensor data
Requires: pip install websockets

Usage:
  python3 ws-publish.py                                    # Continuous publishing with auto-generated messages
  python3 ws-publish.py '{"temp":72.5,"location":"test"}'  # Single publish with custom payload (for testing)
"""

import sys
import json
import random
import asyncio
import websockets


def random_temp():
    """Generate random temperature between 65-85°F"""
    return round(random.uniform(65, 85), 4)


async def publish_once(payload_data):
    """Publish a single message via WebSocket (for testing)"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")

            payload = json.dumps([payload_data])
            await websocket.send(payload)
            print(f"Published: {payload}")

            # Wait for response
            try:
                response = await asyncio.wait_for(websocket.recv(), timeout=3.0)
            except asyncio.TimeoutError:
                pass

            # Give time for message to bridge
            await asyncio.sleep(2)

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


async def publish_continuously():
    """Continuous publishing with auto-generated messages"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")
            print("Publishing every 5 seconds... (Ctrl+C to stop)\n")

            # Publish immediately
            payload = json.dumps([{
                "temp": random_temp(),
                "location": "warehouse"
            }])
            await websocket.send(payload)
            print(f"Published: {payload}")

            # Then publish every 5 seconds
            while True:
                await asyncio.sleep(5)

                payload = json.dumps([{
                    "temp": random_temp(),
                    "location": "warehouse"
                }])

                await websocket.send(payload)
                print(f"Published: {payload}")

    except KeyboardInterrupt:
        print("\nStopping publisher...")
    except Exception as e:
        print(f"Error: {e}")


def main():
    # Check if custom payload provided (for testing)
    custom_payload = sys.argv[1] if len(sys.argv) >= 2 else None

    if custom_payload:
        payload_data = json.loads(custom_payload)
        asyncio.run(publish_once(payload_data))
    else:
        asyncio.run(publish_continuously())


if __name__ == "__main__":
    main()
