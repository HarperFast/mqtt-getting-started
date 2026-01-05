const { EventSource } = require('eventsource');

// Connect to Harper SSE endpoint for sensor 101
// SSE is unidirectional (server to client only)
// To subscribe to all sensors, you would need multiple EventSource connections
// or use a custom Harper resource that broadcasts all sensor updates
const eventSource = new EventSource('http://localhost:9926/Sensors/101', {
  withCredentials: false
});

eventSource.onopen = () => {
  console.log('Connected to Harper SSE');
  console.log('Subscribed to: /Sensors/101');
  console.log('Listening for messages...\n');
};

eventSource.onmessage = (event) => {
  // Receives the current state immediately upon connection,
  // then real-time updates as they're published
  try {
    const payload = JSON.parse(event.data);
    // Harper sends change events with metadata, actual data is in 'value'
    const record = payload.value || payload;
    console.log(`[${new Date().toISOString()}] Update on /Sensors/101:`);
    console.log(`  Temperature: ${record.temp}°F`);
    console.log(`  Location: ${record.location}`);
    console.log('');
  } catch (err) {
    // If message isn't JSON, just log it as-is
    console.log(`[${new Date().toISOString()}] Update on /Sensors/101:`, event.data);
    console.log('');
  }
};

eventSource.onerror = (err) => {
  console.error('SSE error:', err);
  eventSource.close();
  process.exit(1);
};

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\nStopping subscriber...');
  eventSource.close();
  process.exit(0);
});
