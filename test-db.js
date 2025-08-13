const { Pool } = require('pg');
require('dotenv').config();

console.log('Connecting to:', process.env.DATABASE_URL); // Add this line to debug

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function testConnection() {
  try {
    const res = await pool.query('SELECT NOW()');
    console.log('✅ Database connected successfully!');
    console.log('Current time from DB:', res.rows[0].now);
  } catch (err) {
    console.error('❌ Database connection error:', err.message);
  } finally {
    await pool.end();
  }
}

testConnection();