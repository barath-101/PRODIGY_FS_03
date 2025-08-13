# E-commerce Platform

## Project Overview
A full-stack e-commerce platform built with modern web technologies. This project aims to provide a seamless online shopping experience with features like product catalog, user authentication, shopping cart, and order management.

## Key Features
- **User Authentication**: Secure signup and login functionality
- **Product Catalog**: Browsable categories and products
- **Shopping Cart**: Add/remove items, update quantities
- **Order Management**: Track order history and status
- **Admin Dashboard**: Manage products, categories, and orders
- **Responsive Design**: Works on all device sizes

## Tech Stack
- **Frontend**: React.js / Next.js
- **Backend**: Node.js with Express
- **Database**: PostgreSQL (Hosted on Supabase)
- **Authentication**: JWT & OAuth
- **Styling**: Tailwind CSS
- **Deployment**: Vercel / Netlify

## Current Progress (as of August 2024)

###  Completed
1. **Database Setup**
   - Designed and implemented PostgreSQL schema
   - Set up Supabase for database hosting
   - Created tables for users, products, categories, orders, etc.
   - Added sample data for testing

2. **Backend**
   - Set up Node.js project
   - Database connection and configuration
   - Basic API structure

3. **Project Infrastructure**
   - Git repository setup
   - Environment configuration
   - Documentation

##  Database Schema
Key tables include:
- `users`: User accounts and profiles
- `products`: Product information
- `categories`: Product categories and subcategories
- `orders`: Order details
- `order_items`: Individual items in orders
- `reviews`: Product reviews and ratings
- `cart`: Shopping cart items

## Getting Started

### Prerequisites
- Node.js (v16+)
- npm or yarn
- PostgreSQL database (local or hosted)

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/barath-101/PRODIGY_FS_03.git
   cd PRODIGY_FS_03
   ```

2. Install dependencies
   ```bash
   npm install
   ```

3. Set up environment variables
   ```env
   DATABASE_URL=your_database_url
   JWT_SECRET=your_jwt_secret
   # Other environment variables
   ```

4. Start the development server
   ```bash
   npm run dev
   ```

##  Future Goals
- [ ] Implement user authentication
- [ ] Build product catalog pages
- [ ] Create shopping cart functionality
- [ ] Develop checkout process
- [ ] Add admin dashboard
- [ ] Implement payment integration
- [ ] Add product search and filtering
- [ ] Create order tracking system

## 🤝 Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

##  License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.v and copyrighted solely to the Owner  @ BARATH G [barath-101]
