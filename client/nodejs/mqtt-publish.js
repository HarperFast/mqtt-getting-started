#!/usr/bin/env node
const mqtt = require('mqtt');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(4); // 65-85°F
}

// Check if custom payload provided (for testing)
const customPayload = process.argv[2];

// Check retain flag (defaults to true, set MQTT_RETAIN=false for ephemeral messages)
const retain = process.env.MQTT_RETAIN !== 'false';

function publish() {
  const client = mqtt.connect('mqtt://localhost:1883');

  client.on('connect', () => {
    console.log('Connected to MQTT broker');

    if (customPayload) {
      // Single publish with provided payload (for testing)
      client.publish('Sensors/101', customPayload, { qos: 1, retain: retain }, (err) => {
        if (err) {
          console.error('Publish failed:', err);
          process.exit(1);
        }
        console.log(`Published: ${customPayload} (retain: ${retain})`);
        client.end();
        process.exit(0);
      });
    } else {
      // Default: continuous publishing with auto-generated messages
      console.log(`Publishing every 5 seconds (retain: ${retain})... (Ctrl+C to stop)\n`);

      const sendMessage = () => {
        const payload = JSON.stringify({
          temp: parseFloat(randomTemp()),
          location: 'warehouse',
        });

        client.publish('Sensors/101', payload, { qos: 1, retain: retain }, (err) => {
          if (err) {
            console.error('Publish failed:', err);
          } else {
            console.log(`Published: ${payload}`);
          }
        });
      };

      // Publish immediately
      sendMessage();

      // Then publish every 5 seconds
      setInterval(sendMessage, 5000);
    }
  });

  client.on('error', (err) => {
    console.error('Connection error:', err);
    process.exit(1);
  });
}

publish();
