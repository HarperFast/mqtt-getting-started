console.log('Loading Sensors resource...');

export default class Sensors extends tables.Sensors {
    static loadAsInstance = false; // Opt for new behavior

    // Intercept the 'put' (upsert) operation - static method signature
    static put(target, data) {
        console.log(`PUT called for sensor ${id}`);
        if (data.temp > 100) {
            // Logic: Trigger an alert or modify data
            console.log(`ALERT: High temperature detected on sensor ${target.id} - ${data.temp}°F`);
            data.alert = true;
        }
        // Proceed with the default write to storage
        return super.put(target, data);
    }

    // Handle WebSocket connections - static method
    static connect(target, incomingMessages) {
        console.log(`=== CONNECT called for Sensors/ ===`);
        let outgoingMessages = super.connect(target, incomingMessages);
        incomingMessages.on('data', (message) => {
            console.log(`RAW WebSocket message:`, JSON.stringify(message, null, 2));
            // another way of echo-ing the data back to the client
            outgoingMessages.send(message);
        });
        return outgoingMessages;
    }
}

console.log('Sensors resource loaded');
