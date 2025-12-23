const mqtt = require('mqtt');

// Get payload from command line argument
if (process.argv.length < 3) {
  console.error('Usage: node mqtt-publish-test.js \'{"temp":72.5,"location":"test-lab"}\'');
  process.exit(1);
}

const payloadData = JSON.parse(process.argv[2]);
const client = mqtt.connect('mqtt://localhost:1883');

client.on('connect', () => {
  console.log('Connected to MQTT broker');

  const topic = 'Sensors/101';
  const payload = JSON.stringify(payloadData);

  client.publish(topic, payload, { retain: true, qos: 1 }, (err) => {
    if (err) {
      console.error('Publish error:', err);
      process.exit(1);
    } else {
      console.log(`Published: ${payload}`);
      client.end();
    }
  });
});

client.on('error', (err) => {
  console.error('Connection error:', err);
  client.end();
  process.exit(1);
});
