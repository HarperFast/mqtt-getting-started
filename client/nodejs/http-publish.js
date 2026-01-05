#!/usr/bin/env node
/**
 * HTTP Publisher for sensor data (via Harper REST API)
 * Publishing is done via HTTP PUT to /Sensors/101
 *
 * Usage:
 *   node http-publish.js                                    # Continuous publishing with auto-generated messages
 *   node http-publish.js '{"temp":72.5,"location":"test"}'  # Single publish with custom payload (for testing)
 */

const http = require('http');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(4); // 65-85°F
}

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
          resolve(responseData);
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

async function publishOnce(payloadData) {
  try {
    console.log('Connected to Harper (HTTP)');
    await httpPut(payloadData);
    console.log(`Published: ${JSON.stringify(payloadData)}`);
  } catch (err) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }
}

async function publishContinuously() {
  console.log('Connected to Harper (HTTP)');
  console.log('Publishing every 5 seconds... (Ctrl+C to stop)\n');

  const publishInterval = setInterval(async () => {
    const data = {
      temp: randomTemp(),
      location: 'warehouse'
    };

    try {
      await httpPut(data);
      console.log(`Published: ${JSON.stringify(data)}`);
    } catch (err) {
      console.error(`Publish failed: ${err.message}`);
    }
  }, 5000);

  // Handle graceful shutdown
  process.on('SIGINT', () => {
    console.log('\nStopping publisher...');
    clearInterval(publishInterval);
    process.exit(0);
  });
}

// Main execution
const customPayload = process.argv[2];

if (customPayload) {
  const payloadData = JSON.parse(customPayload);
  publishOnce(payloadData);
} else {
  publishContinuously();
}
