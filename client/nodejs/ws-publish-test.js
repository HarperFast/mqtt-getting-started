#!/usr/bin/env node
const WebSocket = require('ws');

// Get payload from command line argument
if (process.argv.length < 3) {
  console.error('Usage: node ws-publish-test.js \'{"temp":72.5,"location":"test-lab"}\'');
  process.exit(1);
}

const payloadData = JSON.parse(process.argv[2]);
const ws = new WebSocket('ws://localhost:9926/Sensors/101');

ws.on('open', () => {
  console.log('Connected to Harper WebSocket');

  // WebSocket expects array format
  const payload = JSON.stringify([payloadData]);

  ws.send(payload, (err) => {
    if (err) {
      console.error('Error sending message:', err);
      process.exit(1);
    } else {
      console.log(`Published: ${payload}`);
      ws.close();
    }
  });
});

ws.on('error', (err) => {
  console.error('WebSocket error:', err.message);
  process.exit(1);
});

ws.on('close', () => {
  process.exit(0);
});
