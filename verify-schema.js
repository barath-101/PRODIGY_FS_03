// verify-schema.js
const { Pool } = require('pg');
require('dotenv').config();

async function verifySchema() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: false
  });

  try {
    // Get all tables and their columns
    const query = `
      SELECT 
        table_name, 
        column_name, 
        data_type,
        is_nullable,
        column_default
      FROM 
        information_schema.columns
      WHERE 
        table_schema = 'public'
      ORDER BY 
        table_name, 
        ordinal_position;
    `;

    const result = await pool.query(query);
    
    // Group columns by table
    const tables = {};
    result.rows.forEach(row => {
      if (!tables[row.table_name]) {
        tables[row.table_name] = [];
      }
      tables[row.table_name].push({
        column: row.column_name,
        type: row.data_type,
        nullable: row.is_nullable === 'YES',
        default: row.column_default
      });
    });

    console.log('Database Schema Verified\n');
    console.log(' Tables and Columns:');
    console.log('======================');
    
    for (const [table, columns] of Object.entries(tables)) {
      console.log(`\n ${table.toUpperCase()}:`);
      console.table(columns);
    }

    // Test data insertion
    console.log('\n Testing data insertion...');
    await testDataInsertion(pool);
    
  } catch (err) {
    console.error('Error verifying schema:', err.message);
  } finally {
    await pool.end();
  }
}

async function testDataInsertion(pool) {
  try {
    // Test inserting a category
    const categoryRes = await pool.query(
      'INSERT INTO categories (name, description) VALUES ($1, $2) RETURNING *',
      ['Test Category', 'A test category']
    );
    console.log('\n Test category inserted:', categoryRes.rows[0]);

    // Test inserting a product
    const productRes = await pool.query(
      'INSERT INTO products (name, description, price, stock_quantity, category_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      ['Test Product', 'A test product', 99.99, 10, categoryRes.rows[0].category_id]
    );
    console.log(' Test product inserted:', productRes.rows[0]);

    // Clean up
    await pool.query('DELETE FROM products WHERE product_id = $1', [productRes.rows[0].product_id]);
    await pool.query('DELETE FROM categories WHERE category_id = $1', [categoryRes.rows[0].category_id]);
    console.log(' Test data cleaned up');

  } catch (err) {
    console.error(' Error testing data insertion:', err.message);
    throw err;
  }
}

verifySchema();