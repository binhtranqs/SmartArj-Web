const { Client } = require('pg');

async function main() {
    const pgClient = new Client({
        connectionString: 'postgresql://neondb_owner:npg_zYsR6tnDoB0x@ep-icy-butterfly-a1e74ayi-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require'
    });
    
    await pgClient.connect();
    
    // Get all tables in public schema
    const tablesRes = await pgClient.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    `);
    
    const tables = tablesRes.rows.map(r => r.table_name);
    console.log("TABLES:", tables);
    
    for (const table of tables) {
        const columnsRes = await pgClient.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = $1
        `, [table]);
        
        console.log(`\nTable ${table}:`);
        for (const col of columnsRes.rows) {
            console.log(`  - ${col.column_name} (${col.data_type})`);
        }
    }
    
    await pgClient.end();
}

main().catch(console.error);
