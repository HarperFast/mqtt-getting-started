const WebSocket = require('ws');

const formats = [
  // Format 1: Plain data
  {
    name: "Plain JSON",
    data: { temp: 70.0, location: 'warehouse' }
  },
  // Format 2: With ID
  {
    name: "Plain JSON with ID",
    data: { id: '101', temp: 75.0, location: 'warehouse' }
  },
  // Format 3: HTTP-like with method and body
  {
    name: "HTTP-like (method/body)",
    data: { method: 'PUT', body: { temp: 80.0, location: 'warehouse' } }
  },
  // Format 4: HTTP-like with method/headers/body
  {
    name: "HTTP-like (method/headers/body)",
    data: { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: { temp: 80.5, location: 'warehouse' } }
  },
  // Format 5: HTTP-like with path
  {
    name: "HTTP-like (method/path/body)",
    data: { method: 'PUT', path: '/Sensors/101', body: { temp: 85.0, location: 'warehouse' } }
  },
  // Format 6: Type and value (Harper outgoing format)
  {
    name: "Type/Value wrapper",
    data: { type: 'put', value: { temp: 85.5, location: 'warehouse' } }
  },
  // Format 7: Type/ID/Value
  {
    name: "Type/ID/Value wrapper",
    data: { type: 'put', id: '101', value: { temp: 90.0, location: 'warehouse' } }
  },
  // Format 8: Action and data
  {
    name: "Action/Data",
    data: { action: 'put', data: { temp: 90.5, location: 'warehouse' } }
  },
  // Format 9: Operation format (like old HarperDB SDK)
  {
    name: "Operation format",
    data: { operation: 'update', table: 'Sensors', id: '101', data: { temp: 95.5, location: 'warehouse' } }
  },
  // Format 10: Transaction format (old SDK style)
  {
    name: "Transaction format",
    data: {
      operation: 'update',
      schema: 'data',
      table: 'Sensors',
      records: [{ id: '101', temp: 75.5, location: 'warehouse' }]
    }
  },
  // Format 11: HDB_TRANSACTION wrapper (old SDK)
  {
    name: "HDB_TRANSACTION wrapper",
    data: {
      type: 'HDB_TRANSACTION',
      transaction: {
        operation: 'update',
        schema: 'data',
        table: 'Sensors',
        records: [{ id: '101', temp: 75.5, location: 'warehouse' }]
      }
    }
  },
  // Format 12: Request format
  {
    name: "Request format",
    data: { request: 'PUT', resource: '/Sensors/101', payload: { temp: 75.5, location: 'warehouse' } }
  },
  // Format 13: URL-style command
  {
    name: "URL command",
    data: { url: '/Sensors/101', method: 'PUT', data: { temp: 75.5, location: 'warehouse' } }
  },
  // Format 14: RESTful command
  {
    name: "RESTful command",
    data: { verb: 'PUT', uri: '/Sensors/101', body: { temp: 75.5, location: 'warehouse' } }
  },
  // Format 15: Message with metadata
  {
    name: "Message with metadata",
    data: {
      metadata: { method: 'PUT', resource: '/Sensors/101' },
      payload: { temp: 75.5, location: 'warehouse' }
    }
  }
];

let currentIndex = 0;

function testFormat() {
  if (currentIndex >= formats.length) {
    console.log('\n=== All formats tested ===');
    process.exit(0);
    return;
  }

  const format = formats[currentIndex];
  console.log(`\n=== Testing format ${currentIndex + 1}/${formats.length}: ${format.name} ===`);
  console.log('Payload:', JSON.stringify(format.data, null, 2));

  const ws = new WebSocket('ws://localhost:9926/Sensors/');

  ws.on('open', () => {
    console.log('Connected');

    setTimeout(() => {
      ws.send(JSON.stringify(format.data));
      console.log('Sent');

      // Wait for any response
      setTimeout(() => {
        ws.close();
      }, 1000);
    }, 100);
  });

  ws.on('message', (data) => {
    console.log('RESPONSE:', data.toString());
  });

  ws.on('error', (err) => {
    console.error('Error:', err.message);
  });

  ws.on('close', () => {
    console.log('Closed');
    currentIndex++;
    // Wait a bit before next test
    setTimeout(testFormat, 1000);
  });
}

console.log('=== WebSocket Message Format Tester ===');
console.log('Testing different message formats against /Sensors/');
console.log('Watch Harper console for any trace logs\n');

testFormat();
