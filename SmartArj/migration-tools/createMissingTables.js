const { Client } = require('pg');

async function main() {
    const pgClient = new Client({
        connectionString: 'postgresql://neondb_owner:npg_zYsR6tnDoB0x@ep-icy-butterfly-a1e74ayi-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require'
    });
    
    await pgClient.connect();
    
    try {
        console.log("Creating city table (mapped as cities)...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS cities (
                cityid SERIAL PRIMARY KEY,
                cityname VARCHAR(100) NOT NULL,
                region VARCHAR(100),
                latitude DOUBLE PRECISION,
                longitude DOUBLE PRECISION
            );
        `);
        
        console.log("Creating zone table (mapped as zones)...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS zones (
                zoneid SERIAL PRIMARY KEY,
                cityid INTEGER NOT NULL,
                ownerid INTEGER,
                zonename VARCHAR(100),
                latitude DOUBLE PRECISION,
                longitude DOUBLE PRECISION,
                description TEXT
            );
        `);

        console.log("Creating cropcatalog table...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS cropcatalog (
                cropcatalogid SERIAL PRIMARY KEY,
                cropname VARCHAR(100) NOT NULL,
                category VARCHAR(50) NOT NULL,
                mintemp DOUBLE PRECISION,
                maxtemp DOUBLE PRECISION,
                minhumid DOUBLE PRECISION,
                maxhumid DOUBLE PRECISION,
                imageurl VARCHAR(500),
                description VARCHAR(500),
                issystemprovided BOOLEAN NOT NULL,
                zoneid INTEGER,
                createdat TIMESTAMP WITHOUT TIME ZONE
            );
        `);
        
        console.log("Creating transactions table...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS transactions (
                transactionid SERIAL PRIMARY KEY,
                amount DOUBLE PRECISION,
                description TEXT,
                providertxnid VARCHAR(64),
                providertxnref VARCHAR(64),
                status VARCHAR(50),
                transdate TIMESTAMP WITHOUT TIME ZONE,
                userid INTEGER,
                vipduration INTEGER
            );
        `);

        console.log("Creating chatlogs table...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS chatlogs (
                logid SERIAL PRIMARY KEY,
                createdat TIMESTAMP WITHOUT TIME ZONE,
                intent VARCHAR(60),
                message VARCHAR(500),
                sessionid VARCHAR(255),
                userid INTEGER,
                wasdbanswer BOOLEAN NOT NULL,
                zoneid INTEGER
            );
        `);

        console.log("Creating alerts table (if not exist)...");
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS alerts (
                alertid SERIAL PRIMARY KEY,
                zoneid INTEGER,
                alerttime TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                message TEXT,
                isread BOOLEAN DEFAULT FALSE
            );
        `);

        console.log("Missing tables created successfully!");

    } catch (err) {
        console.error("Error creating tables:", err);
    } finally {
        await pgClient.end();
    }
}

main();
