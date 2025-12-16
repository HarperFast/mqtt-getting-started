const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://localhost:1883');

client.on('connect', () => {
  console.log('Connected to MQTT broker');

  // Subscribe to sensor 101 topic:
  const topic = 'Sensors/101';
  // Subscribe to all sensor topics (Sensors/101, Sensors/102, etc.)
  // const topic = 'Sensors/#';

  client.subscribe(topic, (err) => {
    if (err) {
      console.error('Subscription error:', err);
    } else {
      console.log(`Subscribed to: ${topic}`);
      console.log('Listening for messages...\n');
    }
  });
});

client.on('message', (topic, message) => {
  // Receives the stored state immediately (retained messages),
  // then real-time updates as they're published
  try {
    const payload = JSON.parse(message.toString());
    console.log(`[${new Date().toISOString()}] Update on ${topic}:`);
    console.log(`  Temperature: ${payload.temp}°F`);
    console.log(`  Location: ${payload.location}`);
    console.log('');
  } catch (err) {
    // If message isn't JSON, just log it as-is
    console.log(`[${new Date().toISOString()}] Update on ${topic}:`, message.toString());
    console.log('');
  }
});

client.on('error', (err) => {
  console.error('Connection error:', err);
  client.end();
});
