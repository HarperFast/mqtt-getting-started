#!/usr/bin/env python3
"""
WebSocket Subscriber for sensor data
Requires: pip install websockets
"""

import json
import asyncio
from datetime import datetime
import websockets


async def subscribe():
    """Subscribe to sensor updates via WebSocket"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")
            print("Subscribed to: Sensors/101")
            print("Listening for messages...\n")

            # Receives the current state immediately upon connection,
            # then real-time updates as they're published
            async for message in websocket:
                try:
                    payload = json.loads(message)
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
                    print(f"[{timestamp}] Update on Sensors/101: {message}")
                    print()
                except Exception as e:
                    print(f"Error processing message: {e}")
                    print()

    except KeyboardInterrupt:
        print("\nStopping subscriber...")
    except Exception as e:
        print(f"Error: {e}")


def main():
    asyncio.run(subscribe())


if __name__ == "__main__":
    main()
