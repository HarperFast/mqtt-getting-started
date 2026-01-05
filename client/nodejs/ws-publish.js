#!/usr/bin/env node
const http = require('http');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(4); // 65-85°F
}

// Check if custom payload provided (for testing)
const customPayload = process.argv[2];

function httpPut(data) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(data);

    const options = {
      hostname: 'localhost',
      port: 9926,
      path: '/Sensors/101',
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = http.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve({ status: res.statusCode, data: responseData });
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${responseData}`));
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(payload);
    req.end();
  });
}

async function publish() {
  console.log('Connected to Harper (HTTP)');

  if (customPayload) {
    // Single publish with provided payload (for testing)
    const payloadData = JSON.parse(customPayload);

    try {
      await httpPut(payloadData);
      console.log(`Published: ${JSON.stringify(payloadData)}`);
      process.exit(0);
    } catch (err) {
      console.error('Publish failed:', err.message);
      process.exit(1);
    }
  } else {
    // Default: continuous publishing with auto-generated messages
    console.log('Publishing every 5 seconds... (Ctrl+C to stop)\n');

    const sendMessage = async () => {
      const data = {
        temp: parseFloat(randomTemp()),
        location: 'warehouse'
      };

      try {
        await httpPut(data);
        console.log(`Published: ${JSON.stringify(data)}`);
      } catch (err) {
        console.error('Publish failed:', err.message);
      }
    };

    // Publish immediately
    await sendMessage();

    // Then publish every 5 seconds
    setInterval(sendMessage, 5000);
  }
}

publish();
