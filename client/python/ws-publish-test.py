#!/usr/bin/env python3
"""
WebSocket Test Publisher - accepts JSON payload as command-line argument
Usage: python3 ws-publish-test.py '{"temp":72.5,"location":"test-lab"}'
"""

import sys
import json
import asyncio
import websockets

if len(sys.argv) < 2:
    print('Usage: python3 ws-publish-test.py \'{"temp":72.5,"location":"test-lab"}\'')
    sys.exit(1)

# Parse payload from command line
payload_data = json.loads(sys.argv[1])

async def publish():
    """Publish a single message via WebSocket"""
    uri = "ws://localhost:9926/Sensors/101"

    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to Harper WebSocket")

            # WebSocket expects array format (matching ws-publish.js behavior)
            payload = json.dumps([payload_data])

            await websocket.send(payload)
            print(f"Published: {payload}")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def main():
    asyncio.run(publish())

if __name__ == "__main__":
    main()
