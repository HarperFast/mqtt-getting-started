const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://localhost:1883');

// Helper to generate random temperature
function randomTemp() {
  return (Math.random() * 20 + 65).toFixed(1); // 65-85°F
}

client.on('connect', () => {
  console.log('Connected to MQTT broker');

  // Topic maps directly to the 'sensors' table, record ID '101'
  const topic = 'sensors/101';

  // ============================================================
  // TIER 0: MVP - Single publish, no database persistence
  // ============================================================
  const payload = JSON.stringify({
    temp: parseFloat(randomTemp()),
    location: 'warehouse'
  });

  // ============================================================
  // TIER 1: Enable database persistence - uncomment to enable
  // Replace retain: false with retain: true above
  // ============================================================
  // client.publish(topic, payload, { retain: true, qos: 1 }, (err) => {
  client.publish(topic, payload, { retain: false, qos: 1 }, (err) => {
    if (err) {
      console.error('Publish error:', err);
    } else {
      console.log(`Published: ${payload}`);
    }
    client.end();
  });

  
  /*
  const payload = JSON.stringify({
    temp: parseFloat(randomTemp()),
    location: 'warehouse'
  });

  // Retain = true means "Upsert this record to the database"
    if (err) {
      console.error('Publish error:', err);
    } else {
      console.log(`Published: ${payload}`);
    }
    client.end();
  });
  */

  // ============================================================
  // TIER 2: Continuous publishing - uncomment to enable
  // Comment out Tier 0/1 single publish code above
  // ============================================================
  /*
  setInterval(() => {
    const payload = JSON.stringify({
      temp: parseFloat(randomTemp()),
      location: 'warehouse'
    });

    // Retain = true means "Upsert this record to the database"
    client.publish(topic, payload, { retain: true, qos: 1 }, (err) => {
      if (err) {
        console.error('Publish error:', err);
      } else {
        console.log(`Published: ${payload}`);
      }
    });
  }, 5000); // Publish every 5 seconds
  */
});

client.on('error', (err) => {
  console.error('Connection error:', err);
  client.end();
});
