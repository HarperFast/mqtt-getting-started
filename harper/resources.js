export default class Sensors extends tables.Sensors {
    static loadAsInstance = false; // opt in to updated behavior
    // Intercept the 'put' (upsert) operation
    put(target, data) {
        if (data.temp > 100) {
            // Logic: Trigger an alert or modify data
            console.log(`ALERT: High temperature detected on sensor ${target.id}`);
            data.alert = true;
        }
        // Proceed with the default write to storage
        return super.put(target, data);
    }
}
