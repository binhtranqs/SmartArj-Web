require('dotenv').config();
const { Client: PgClient } = require('pg');
const sql = require('mssql');

const mssqlConfig = {
    user: 'sa',
    password: 'YourStrong@123',
    server: 'localhost',
    database: 'SmartAgri_PRJ301',
    port: 1433,
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
};

const pgConfig = {
    connectionString: 'postgresql://neondb_owner:npg_zYsR6tnDoB0x@ep-icy-butterfly-a1e74ayi-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require'
};

/* Helper to execute with fallback to ignore conflicts */
async function queryPg(pgClient, query, params) {
    try {
        await pgClient.query(query, params);
    } catch (e) {
        if (e.code !== '23505') { // If not duplicate key violation
             console.error('PG Error on:', query, params, e.message);
        }
    }
}

async function migrateData() {
    const pgClient = new PgClient(pgConfig);
    await pgClient.connect();

    try {
        await sql.connect(mssqlConfig);
        console.log('Connected to MSSQL and PostgreSQL!');

        // 1. Migrate Users
        console.log('Migrating Users...');
        const usersRes = await sql.query('SELECT * FROM Users');
        if (usersRes.recordset.length > 0) {
            console.log('User columns:', Object.keys(usersRes.recordset[0]));
        }
        for (const r of usersRes.recordset) {
            await queryPg(pgClient, `
                INSERT INTO users 
                (userid, username, passwordhash, email, fullname, role, accounttype, 
                isactive, lockreason, vipexpirydate, lastlogin, createdat)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                ON CONFLICT (userid) DO NOTHING;
            `, [
                r.UserID, r.Username, r.PasswordHash || 'NOPASSWORD', r.Email || `${r.Username}@example.com`, r.FullName || r.Username, r.Role,
                r.AccountType || 'LOCAL', r.IsActive ?? true, r.LockReason || null, r.VIPExpiryDate || null, r.LastLogin || null, r.CreatedAt || new Date()
            ]);
        }

        // 2. Migrate Cities
        console.log('Migrating Cities...');
        const citiesRes = await sql.query('SELECT * FROM Cities');
        for (const r of citiesRes.recordset) {
            await queryPg(pgClient, `
                INSERT INTO cities (cityid, cityname, region, latitude, longitude)
                VALUES ($1, $2, $3, $4, $5)
            `, [r.CityID, r.CityName, r.Region || null, r.Latitude || null, r.Longitude || null]);
        }

        // 3. Migrate Zones
        console.log('Migrating Zones...');
        const zonesRes = await sql.query('SELECT * FROM Zones');
        for (const r of zonesRes.recordset) {
            await queryPg(pgClient, `
                INSERT INTO zones (zoneid, cityid, ownerid, zonename, latitude, longitude, description)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
            `, [r.ZoneID, r.CityID, r.OwnerID, r.ZoneName, r.Latitude, r.Longitude, r.Description]);
        }

        // 4. Migrate WeatherLogs
        console.log('Migrating WeatherLogs...');
        let wlRes;
        try {
             wlRes = await sql.query('SELECT * FROM WeatherLogs');
        } catch(e) { console.log('No WeatherLogs in MSSQL'); }
        if (wlRes) {
            let wCount = 0;
            for (const r of wlRes.recordset) {
                await queryPg(pgClient, `
                    INSERT INTO weatherlogs (logid, zoneid, recordedat, temperature, humidity, rainfall, wind, radiation)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                `, [r.LogID, r.ZoneID, r.RecordedAt, r.Temperature, r.Humidity, r.Rainfall, r.Wind, r.Radiation]);
                wCount++;
                if (wCount % 100 === 0) console.log(`Migrated ${wCount} weather logs...`);
            }
        }

        // 5. Migrate Crops from CropCatalog
        console.log('Migrating Crops...');
        let cropsRes;
        try {
             cropsRes = await sql.query('SELECT * FROM CropCatalog');
        } catch(e) { console.log('No CropCatalog in MSSQL', e.message); }
        if (cropsRes && cropsRes.recordset.length > 0) {
            console.log('CropCatalog columns:', Object.keys(cropsRes.recordset[0]));
            for (const r of cropsRes.recordset) {
                // In Postgres it's cropcatalogid, cropname, category, mintemp, maxtemp, minhumid, maxhumid, imageurl, description, issystemprovided, zoneid, createdat
                // In SQL Server CropCatalog has columns? We will map what we can.
                await queryPg(pgClient, `
                    INSERT INTO cropcatalog (cropcatalogid, cropname, category, mintemp, maxtemp, minhumid, maxhumid, imageurl, description, issystemprovided, zoneid, createdat)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, CURRENT_TIMESTAMP)
                    ON CONFLICT (cropcatalogid) DO NOTHING;
                `, [
                    r.CropCatalogID || r.CropID || r.id, 
                    r.CropName || r.name, 
                    r.Category || 'Unknown', 
                    r.MinTemp || 0, 
                    r.MaxTemp || 0, 
                    r.MinHumid || 0, 
                    r.MaxHumid || 0, 
                    r.ImageUrl || null, 
                    r.Description || null, 
                    r.IsSystemProvided ?? true, 
                    r.ZoneID || null
                ]);
            }
        }
        
        // Fix sequences
        const tablesToFix = ['users', 'cities', 'zones', 'weatherlogs', 'cropcatalog'];
        const idProps = ['userid', 'cityid', 'zoneid', 'logid', 'cropcatalogid'];
        for (let i = 0; i < tablesToFix.length; i++) {
           try {
               await pgClient.query(`
                   SELECT setval(pg_get_serial_sequence($1, $2), COALESCE((SELECT MAX(${idProps[i]}) FROM ${tablesToFix[i]}), 0) + 1, false);
               `, [tablesToFix[i], idProps[i]]);
           } catch(e) {
               console.log("Could not fix sequence for " + tablesToFix[i]);
           }
        }

        console.log('Migration Completed Successfully!');
    } catch (err) {
        console.error('Migration failed:', err);
    } finally {
        await sql.close();
        await pgClient.end();
    }
}

migrateData();
