#!/usr/bin/env python3
"""
WebSocket Publisher for sensor data
Requires: pip install websockets
"""

import json
import random
import asyncio
import websockets


def random_temp():
    """Generate random temperature between 65-85°F"""
    return round(random.uniform(65, 85), 1)


# ============================================================
# TIER 0: MVP - Single publish
# ============================================================
async def publish_once():
    """Publish a single message via WebSocket"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")

            # Format message like HTTP request with method, headers, and body
            payload = json.dumps({
                "method": "PUT",
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": {
                    "temp": random_temp(),
                    "location": "warehouse"
                }
            })

            await websocket.send(payload)
            print(f"Published: {payload}")

    except Exception as e:
        print(f"Error: {e}")


# ============================================================
# TIER 1: Enable database persistence
# WebSocket messages to Harper resources are automatically persisted
# ============================================================

# ============================================================
# TIER 2: Continuous publishing - uncomment to enable
# Replace the main() function below with this version
# ============================================================
"""
async def publish_continuously():
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")
            print("Publishing every 5 seconds... (Ctrl+C to stop)\n")

            # Publish immediately with HTTP-like format
            payload = json.dumps({
                "method": "PUT",
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": {
                    "temp": random_temp(),
                    "location": "warehouse"
                }
            })
            await websocket.send(payload)
            print(f"Published: {payload}")

            # Then publish every 5 seconds
            while True:
                await asyncio.sleep(5)

                payload = json.dumps({
                    "method": "PUT",
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "body": {
                        "temp": random_temp(),
                        "location": "warehouse"
                    }
                })

                await websocket.send(payload)
                print(f"Published: {payload}")

    except KeyboardInterrupt:
        print("\nStopping publisher...")
    except Exception as e:
        print(f"Error: {e}")
"""


def main():
    # Run TIER 0 by default
    asyncio.run(publish_once())

    # Uncomment for TIER 2:
    # asyncio.run(publish_continuously())


if __name__ == "__main__":
    main()
