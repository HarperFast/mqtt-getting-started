const WebSocket = require('ws');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 40 + 65).toFixed(1); // 65-85°F
}

function publish(once) {
  // Try collection endpoint instead of specific record
  const ws = new WebSocket('ws://localhost:9926/Sensors/101');

  ws.on('open', () => {
    console.log('Connected to Harper WebSocket');
    console.log('WebSocket ready state:', ws.readyState);
    console.log('WebSocket URL:', ws.url);
    console.log('Publishing every 5 seconds... (Ctrl+C to stop)\n');

    // Publish immediately
    const sendMessage = () => {
      const payload = JSON.stringify([{
          "temp": parseFloat(randomTemp()),
          "location": 'warehouse' 
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

    sendMessage();

    if (! once) {
      // Then publish every 5 seconds
      setInterval(sendMessage, 5000);
    }
  });

  ws.on('message', (data) => {
    console.log('Received response from server:', data.toString());
    try {
      const parsed = JSON.parse(data.toString());
      console.log('Parsed response:', JSON.stringify(parsed, null, 2));
    } catch (e) {
      console.log('Response is not JSON: ', e.message);
    }
  });

  ws.on('error', (err) => {
    console.error('WebSocket error:');
    console.error('  Message:', err.message);
    console.error('  Code:', err.code);
    console.error('  Stack:', err.stack);
    process.exit(1);
  });

  ws.on('close', (code, reason) => {
    console.log(`Connection closed. Code: ${code}, Reason: ${reason || 'No reason provided'}`);
    process.exit(0);
  });
}

// true = one-time publish and exit
// false = continuous publishing every 5 seconds
let once = false;

publish(once);
