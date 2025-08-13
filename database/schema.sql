-- =============================================
-- E-commerce Database Schema
-- Created: 2025-08-13
-- Last Updated: 2025-08-13
-- Description: SQL schema for the e-commerce application database
-- =============================================

/*
DATABASE SCHEMA DOCUMENTATION

This schema defines the structure for an e-commerce platform with the following key features:
- User management with authentication
- Product catalog with categories and subcategories
- Shopping cart functionality
- Order processing
- Product reviews and ratings

TABLE RELATIONSHIPS:
1. categories (self-referencing for subcategories)
   └─┬ products (category_id)
     ├── product_images (product_id)
     ├── order_items (product_id)
     ├── reviews (product_id)
     └── cart (product_id)

2. users
   ├── orders (user_id)
   ├── reviews (user_id)
   └── cart (user_id)

3. orders
   └── order_items (order_id)

SAMPLE QUERIES:
--------------
1. Get all products with their categories:
   SELECT p.*, c.name as category_name 
   FROM products p 
   JOIN categories c ON p.category_id = c.category_id;

2. Get a user's cart with product details:
   SELECT c.*, p.name, p.price, p.discount_price
   FROM cart c
   JOIN products p ON c.product_id = p.product_id
   WHERE c.user_id = :userId;

3. Get order history for a user:
   SELECT o.*, oi.quantity, p.name as product_name,
          (oi.quantity * oi.unit_price) as item_total
   FROM orders o
   JOIN order_items oi ON o.order_id = oi.order_id
   JOIN products p ON oi.product_id = p.product_id
   WHERE o.user_id = :userId
   ORDER BY o.order_date DESC;
*/

-- =============================================

-- Enable UUID extension (useful for generating unique IDs if needed in the future)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS cart CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_images CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    shipping_address TEXT,
    phone_number VARCHAR(20),
    is_admin BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Create products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    image_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    discount_price DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create product_images table
CREATE TABLE product_images (
    image_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    shipping_address TEXT NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    payment_method VARCHAR(50),
    tracking_number VARCHAR(100),
    notes TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create reviews table
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, user_id)  -- One review per product per user
);

-- Create cart table
CREATE TABLE cart (
    cart_item_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)  -- One product per user in cart
);

-- Create indexes for better performance
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_cart_user ON cart(user_id);

-- Add comments to tables and columns
COMMENT ON TABLE categories IS 'Stores product categories for the e-commerce site';
COMMENT ON TABLE users IS 'Stores user account information';
COMMENT ON TABLE products IS 'Stores product information';
COMMENT ON TABLE product_images IS 'Stores multiple images for each product';
COMMENT ON TABLE orders IS 'Stores order headers';
COMMENT ON TABLE order_items IS 'Stores individual items within orders';
COMMENT ON TABLE reviews IS 'Stores product reviews and ratings';
COMMENT ON TABLE cart IS 'Stores shopping cart items';

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

/*
SAMPLE PRODUCT DATA
------------------
The following SQL inserts sample products and their images into the database.
The structure supports multiple image formats (JPG, JPEG, AVIF, WebP) and handles
primary/secondary images appropriately.
*/

-- Insert sample categories with hierarchical structure
INSERT INTO categories (name, description, parent_id) VALUES 
-- Main Categories
('Electronics', 'Electronic devices and accessories', NULL),
('Clothing', 'Apparel and fashion items', NULL),
('Home & Living', 'Furniture and home decor', NULL),
('Beauty & Personal Care', 'Cosmetics and personal care products', NULL),
('Books & Media', 'Books, movies, and music', NULL),

-- Subcategories for Electronics
('Smartphones & Accessories', 'Mobile phones and related accessories', 1),
('Laptops & Computers', 'Laptops, desktops, and computing devices', 1),
('Audio & Headphones', 'Speakers, headphones, and audio equipment', 1),
('Wearable Technology', 'Smartwatches and fitness trackers', 1),

-- Subcategories for Clothing
('Men''s Clothing', 'Clothing for men', 2),
('Women''s Clothing', 'Clothing for women', 2),
('Kid''s Clothing', 'Clothing for children', 2),
('Accessories', 'Fashion accessories', 2);

-- Insert sample products
WITH product_data AS (
    SELECT 
        name,
        description,
        (SELECT category_id FROM categories WHERE name = category_name) as category_id,
        price,
        discount_price,
        stock_quantity,
        image_url
    FROM (
        VALUES
            ('iPhone 14 Pro', 'Latest iPhone with A16 Bionic chip, 48MP camera', 'Smartphones & Accessories', 999.00, 949.00, 87, '/images/products/1/1.jpg'),
            ('MacBook Pro 14" M2', '14.2" Liquid Retina XDR display, M2 Pro chip', 'Laptops & Computers', 1999.00, 1899.00, 42, '/images/products/2/1.jpg'),
            ('Premium Cotton T-Shirt', '100% organic cotton, pre-shrunk', 'Men''s Clothing', 29.99, 24.99, 156, '/images/products/3/1.jpg'),
            ('The Midnight Library', 'Novel by Matt Haig about life choices', 'Fiction Books', 15.99, 12.99, 231, '/images/products/4/1.avif'),
            ('Vitamin C Brightening Serum', '20% Vitamin C with Ferulic Acid', 'Skincare', 34.99, 29.99, 78, '/images/products/5/1.webp')
    ) AS t(name, description, category_name, price, discount_price, stock_quantity, image_url)
)
INSERT INTO products (name, description, category_id, price, discount_price, stock_quantity, image_url, is_active)
SELECT name, description, category_id, price, discount_price, stock_quantity, image_url, true
FROM product_data;

-- Insert product images
-- Note: The actual paths should match your file structure
DO $$
BEGIN
    -- iPhone 14 Pro (5 JPG images)
    INSERT INTO product_images (product_id, image_url, is_primary) VALUES
    (1, '/images/products/1/1.jpg', true),
    (1, '/images/products/1/2.jpg', false),
    (1, '/images/products/1/3.jpg', false),
    (1, '/images/products/1/4.jpg', false),
    (1, '/images/products/1/5.jpg', false);

    -- MacBook Pro (5 JPG images)
    INSERT INTO product_images (product_id, image_url, is_primary) VALUES
    (2, '/images/products/2/1.jpg', true),
    (2, '/images/products/2/2.jpg', false),
    (2, '/images/products/2/3.jpg', false),
    (2, '/images/products/2/4.jpg', false),
    (2, '/images/products/2/5.jpg', false);

    -- T-Shirt (1 JPG + 4 JPEG images)
    INSERT INTO product_images (product_id, image_url, is_primary) VALUES
    (3, '/images/products/3/1.jpg', true),
    (3, '/images/products/3/2.jpeg', false),
    (3, '/images/products/3/3.jpeg', false),
    (3, '/images/products/3/4.jpeg', false),
    (3, '/images/products/3/5.jpeg', false);

    -- Book (5 AVIF images)
    INSERT INTO product_images (product_id, image_url, is_primary) VALUES
    (4, '/images/products/4/1.avif', true),
    (4, '/images/products/4/2.avif', false),
    (4, '/images/products/4/3.avif', false),
    (4, '/images/products/4/4.avif', false),
    (4, '/images/products/4/5.avif', false);

    -- Serum (1 WebP + 4 JPG images)
    INSERT INTO product_images (product_id, image_url, is_primary) VALUES
    (5, '/images/products/5/1.webp', true),
    (5, '/images/products/5/2.jpg', false),
    (5, '/images/products/5/3.jpg', false),
    (5, '/images/products/5/4.jpg', false),
    (5, '/images/products/5/5.jpg', false);
END $$;

-- Insert sample admin user (password: password123 - hash this in production)
INSERT INTO users (username, email, password_hash, is_admin) VALUES 
('admin', 'admin@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', TRUE);

/*
QUERIES FOR REFERENCE:
-------------------
-- Get all products with their categories and images
SELECT 
    p.product_id,
    p.name as product_name,
    p.price,
    p.stock_quantity,
    c.name as category_name,
    pi.image_url as main_image
FROM 
    products p
JOIN 
    categories c ON p.category_id = c.category_id
JOIN 
    product_images pi ON p.product_id = pi.product_id AND pi.is_primary = true;

-- Get all images for a specific product
SELECT 
    p.name as product_name,
    pi.image_url,
    pi.is_primary
FROM 
    product_images pi
JOIN 
    products p ON pi.product_id = p.product_id
WHERE 
    p.product_id = 1
ORDER BY 
    pi.is_primary DESC;
*/
