// import-schema.js
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function importSchema() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: false
  });

  try {
    // Read the schema.sql file
    const schema = fs.readFileSync(
      path.join(__dirname, 'database', 'schema.sql'), 
      'utf8'
    );
    
    console.log('📝 Importing schema...');
    await pool.query(schema);
    console.log('✅ Schema imported successfully!');
    
    // Verify tables were created
    const res = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);
    
    console.log('\n📊 Tables created:');
    console.table(res.rows);
    
  } catch (err) {
    console.error('❌ Error importing schema:', err.message);
  } finally {
    await pool.end();
  }
}

importSchema();