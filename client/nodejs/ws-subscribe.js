const WebSocket = require('ws');

// Connect to Harper WebSocket endpoint for sensor 101
// To subscribe to all sensors, you would need to connect to each individually
// or use a custom Harper resource that broadcasts all sensor updates
const ws = new WebSocket('ws://localhost:9926/Sensors/101');

ws.on('open', () => {
  console.log('Connected to Harper WebSocket');
  console.log('Subscribed to: Sensors/101');
  console.log('Listening for messages...\n');
});

ws.on('message', (data) => {
  // Receives the current state immediately upon connection,
  // then real-time updates as they're published
  try {
    const payload = JSON.parse(data.toString());
    // Harper sends change events with metadata, actual data is in 'value'
    const record = payload.value || payload;
    console.log(`[${new Date().toISOString()}] Update on Sensors/101:`);
    console.log(`  Temperature: ${record.temp}°F`);
    console.log(`  Location: ${record.location}`);
    console.log('');
  } catch (err) {
    // If message isn't JSON, just log it as-is
    console.log(`[${new Date().toISOString()}] Update on Sensors/101:`, data.toString());
    console.log('');
  }
});

ws.on('error', (err) => {
  console.error('WebSocket error:', err);
  process.exit(1);
});

ws.on('close', () => {
  console.log('Connection closed');
  process.exit(0);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\nStopping subscriber...');
  ws.close();
});
