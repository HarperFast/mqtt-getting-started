const WebSocket = require('ws');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(1); // 65-85°F
}

// ============================================================
// TIER 0: MVP - Single publish, no database persistence
// ============================================================
function publishOnce() {
  // Connect to Sensors/101 resource
  const ws = new WebSocket('ws://localhost:9926/Sensors/101');

  ws.on('open', () => {
    console.log('Connected to Harper WebSocket');
    console.log('WebSocket ready state:', ws.readyState);
  });

  ws.on('message', (data) => {
    console.log('Received response from server:', data.toString());
  });

  ws.on('error', (err) => {
    console.error('WebSocket error:', err);
  });

  ws.on('close', (code, reason) => {
    console.log(`Connection closed. Code: ${code}, Reason: ${reason}`);
  });

  // Wait a bit after open, then send
  setTimeout(() => {
    if (ws.readyState === WebSocket.OPEN) {
      const payload = JSON.stringify({
        id: '101',
        temp: parseFloat(randomTemp()),
        location: 'warehouse'
      });

      console.log(`Sending: ${payload}`);
      ws.send(payload);

      // Keep connection open longer to see any responses
      setTimeout(() => ws.close(), 2000);
    }
  }, 500);

  ws.on('close', () => {
    console.log('Connection closed');
  });
}

// ============================================================
// TIER 1: Enable database persistence
// WebSocket messages to Harper resources are automatically persisted
// ============================================================

// ============================================================
// TIER 2: Continuous publishing - uncomment to enable
// Comment out publishOnce() below and uncomment this section
// ============================================================
function publishContinuously() {
  // Try collection endpoint instead of specific record
  const ws = new WebSocket('ws://localhost:9926/Sensors/');

  ws.on('open', () => {
    console.log('Connected to Harper WebSocket');
    console.log('Publishing every 5 seconds... (Ctrl+C to stop)\n');

    // Publish immediately with HTTP-like format
    const payload = JSON.stringify({
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: {
        temp: parseFloat(randomTemp()),
        location: 'warehouse'
      }
    });
    ws.send(payload);
    console.log(`Published: ${payload}`);

    // Then publish every 5 seconds
    setInterval(() => {
      const payload = JSON.stringify({
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: {
          temp: parseFloat(randomTemp()),
          location: 'warehouse'
        }
      });
      ws.send(payload);
      console.log(`Published: ${payload}`);
    }, 5000);
  });

  ws.on('error', (err) => {
    console.error('WebSocket error:', err);
    process.exit(1);
  });

  ws.on('close', () => {
    console.log('Connection closed');
    process.exit(0);
  });
}

// Run TIER 0 by default
// publishOnce();
// Uncomment for TIER 2:
publishContinuously();
