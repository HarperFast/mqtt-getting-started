#!/usr/bin/env node
const WebSocket = require('ws');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(4); // 65-85°F
}

// Check if custom payload provided (for testing)
const customPayload = process.argv[2];

function publish() {
  const ws = new WebSocket('ws://localhost:9926/Sensors/101');

  ws.on('open', () => {
    console.log('Connected to Harper WebSocket');

    if (customPayload) {
      // Single publish with provided payload (for testing)
      const payloadData = JSON.parse(customPayload);
      const payload = JSON.stringify([payloadData]);

      try {
        ws.send(payload, (err) => {
          if (err) {
            console.error('Error sending message:', err);
          } else {
            console.log(`Published: ${payload}`);
          }
        });
      } catch (err) {
        console.error('Exception while sending:', err);
        process.exit(1);
      }
    } else {
      // Default: continuous publishing with auto-generated messages
      console.log('Publishing every 5 seconds... (Ctrl+C to stop)\n');

      const sendMessage = () => {
        const payload = JSON.stringify([{
          temp: parseFloat(randomTemp()),
          location: 'warehouse'
        }]);

        try {
          ws.send(payload, (err) => {
            if (err) {
              console.error('Error sending message:', err);
            } else {
              console.log(`Published: ${payload}`);
            }
          });
        } catch (err) {
          console.error('Exception while sending:', err);
        }
      };

      // Publish immediately
      sendMessage();

      // Then publish every 5 seconds
      setInterval(sendMessage, 5000);
    }
  });

  ws.on('message', (data) => {
    if (customPayload) {
      // When using custom payload, wait after response then close
      setTimeout(() => ws.close(), 2000);
    }
    // Otherwise just log the response
  });

  ws.on('error', (err) => {
    console.error('WebSocket error:');
    console.error('  Message:', err.message);
    console.error('  Code:', err.code);
    console.error('  Stack:', err.stack);
    process.exit(1);
  });

  ws.on('close', (code, reason) => {
    if (customPayload) {
      process.exit(0);
    } else {
      console.log(`Connection closed. Code: ${code}, Reason: ${reason || 'No reason provided'}`);
      process.exit(0);
    }
  });
}

publish();
