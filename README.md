# 🎗️ Donare – Donation Management System

![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?logo=javascript&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green)

**Donare** is a comprehensive, full-stack donation management platform that connects donors with verified NGOs and charitable campaigns. Built with PHP, MySQL, and vanilla JavaScript, it provides a secure, user-friendly interface for managing donations, campaigns, and organizational transparency.

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Database Setup](#-database-setup)
- [Configuration](#-configuration)
- [Running the Project](#-running-the-project)
- [API Documentation](#-api-documentation)
- [Folder Structure](#-folder-structure)
- [User Roles](#-user-roles)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🌟 Overview

Donare simplifies the donation process by providing:
- A transparent platform where donors can browse verified campaigns
- Real-time tracking of donation progress toward campaign goals
- Role-based access for administrators, NGO trustees, and regular users
- Secure payment processing with transaction limits and validation
- Complete donation history and tax receipt generation

---

## ✨ Features

### For Donors
- 🏠 **Campaign Discovery** – Browse campaigns by category (Education, Environment, Humanitarian, Energy, Health)
- 💳 **Secure Donations** – Support via Bank Transfer or Card Payment with built-in validation
- 📊 **Progress Tracking** – Real-time progress bars showing campaign funding status
- 📜 **Donation History** – View all past donations with receipt IDs
- 🔒 **Smart Donation Caps** – Prevents over-funding with automatic goal limits

### For NGO Trustees
- 📈 **Dashboard** – View campaigns, donation statistics, and historical data
- 📋 **Campaign Management** – Monitor active campaigns under their organization
- 📚 **Transparency Reports** – Historical data showing funds raised, distributed, and beneficiaries served

### For Administrators
- 🎯 **Campaign CRUD** – Create, read, update, and delete campaigns
- 👥 **Donation Management** – View all donations with the ability to delete/reverse
- 📩 **Support Tickets** – Manage user support messages and inquiries
- 🔧 **NGO Management** – Oversee all registered NGOs

### Security Features
- 🛡️ **XSS Prevention** – Input sanitization and HTML escaping
- 🔐 **SQL Injection Protection** – Prepared statements throughout
- 🤖 **Bot Protection** – Honeypot fields on forms
- 💰 **Transaction Limits** – ₹10,000 per transaction limit
- 🔑 **Password Hashing** – bcrypt with PHP's `password_hash()`

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript (ES6+) |
| **Backend** | PHP 8.3+ |
| **Database** | MySQL 8.0+ |
| **Server** | Apache (WAMP/XAMPP/LAMP) |
| **Fonts** | Google Fonts (Playfair Display, DM Sans) |

---

## 📸 Screenshots

> Add screenshots of your application here:
> - Home page with campaign cards
> - Donation form with payment options
> - Admin dashboard
> - Trustee NGO view

---

## 🚀 Installation

### Prerequisites

- **PHP** 8.0 or higher
- **MySQL** 8.0 or higher
- **Apache** web server (or Nginx with PHP-FPM)
- **WAMP/XAMPP/MAMP** (for local development on Windows/Mac)

### Step-by-Step Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/donare-v.git
   cd donare-v
   ```

2. **Move to web server directory**
   
   For WAMP:
   ```bash
   # Move to C:\wamp64\www\donare-v
   ```
   
   For XAMPP:
   ```bash
   # Move to C:\xampp\htdocs\donare-v
   ```

3. **Configure environment** (see [Configuration](#-configuration))

4. **Set up database** (see [Database Setup](#-database-setup))

5. **Start your web server** and navigate to:
   ```
   http://localhost/donare-v/donare.html
   ```

---

## 🗄️ Database Setup

### Option 1: Import SQL File

1. Open **phpMyAdmin** or your MySQL client
2. Create a new database named `donare_db`
3. Import the `donare_db.sql` file:
   ```bash
   mysql -u root -p donare_db < donare_db.sql
   ```

### Option 2: Manual Setup

1. Create the database:
   ```sql
   CREATE DATABASE donare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

2. The SQL file will create these tables:
   - `users` – Regular donor accounts
   - `admins` – Administrator accounts
   - `trustees` – NGO trustee accounts
   - `ngos` – Registered organizations
   - `campaigns` – Active fundraising campaigns
   - `donations` – Donation records
   - `ngo_history` – Historical transparency data
   - `support_messages` – User support tickets

### Database Schema Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    users    │     │   admins    │     │  trustees   │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id          │     │ id          │     │ id          │
│ name        │     │ name        │     │ name        │
│ email       │     │ email       │     │ email       │
│ password    │     │ password    │     │ password    │
│ role        │     │ created_at  │     │ ngo_name    │
│ created_at  │     └─────────────┘     │ created_at  │
└─────────────┘                         └─────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    ngos     │────<│  campaigns  │────<│  donations  │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id          │     │ id          │     │ id          │
│ name        │     │ title       │     │ receipt_id  │
│ description │     │ ngo_id (FK) │     │ campaign_id │
│ created_at  │     │ category    │     │ user_id     │
└─────────────┘     │ goal        │     │ donor_name  │
                    │ raised      │     │ amount      │
                    │ donors      │     │ status      │
                    │ days_left   │     │ donated_at  │
                    │ image_url   │     └─────────────┘
                    │ description │
                    │ is_active   │
                    └─────────────┘
```

---

## ⚙️ Configuration

### Database Connection

Edit `api/db.php` to configure your database connection:

```php
// Local development (default)
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'donare_db');

// Production - update these values
define('DB_HOST', 'your-db-host.com');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
define('DB_NAME', 'your_database_name');
```

### Environment Variables

Create a `.env` file from the template:
```bash
cp .env.example .env
```

Then update the values:
```env
DB_HOST=localhost
DB_USER=root
DB_PASS=your_password
DB_NAME=donare_db
```

### API Base URL

Update `main.js` if your project path differs:
```javascript
const API = "/donare-v/api";  // Adjust to your path
```

---

## 🖥️ Running the Project

### Local Development

1. **Start WAMP/XAMPP/MAMP**
2. **Ensure Apache and MySQL are running**
3. **Access the application:**
   ```
   http://localhost/donare-v/donare.html
   ```

### Test Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@gmail.com | `password` |
| Trustee | waterfirst@gmail.com | `password` |
| User | ahmad.rahman@email.com | `password` |

> ⚠️ **Note:** These are demo accounts. Change passwords for production use!

---

## 📡 API Documentation

All API endpoints are located in the `/api` directory and return JSON responses.

### Authentication

#### POST `/api/login.php`
Authenticate a user and receive session data.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

**Response:**
```json
{
  "success": true,
  "id": 1,
  "name": "User Name",
  "email": "user@example.com",
  "role": "user"
}
```

#### POST `/api/signup.php`
Register a new user account.

**Request Body:**
```json
{
  "name": "New User",
  "email": "newuser@example.com",
  "password": "securepassword"
}
```

---

### Campaigns

#### GET `/api/campaigns.php`
Retrieve all active campaigns.

**Response:**
```json
[
  {
    "id": 1,
    "title": "Clean Water Wells",
    "category": "Environment",
    "goal": 45000.00,
    "raised": 28450.00,
    "donors": 12,
    "days_left": 38,
    "image_url": "https://...",
    "description": "...",
    "ngo": "WaterFirst NGO",
    "remaining_to_goal": 16550.00,
    "max_allowed_donation": 10000,
    "goal_reached": false
  }
]
```

---

### Donations

#### POST `/api/donate.php`
Process a new donation.

**Request Body:**
```json
{
  "campaign_id": 1,
  "donor_name": "John Doe",
  "donor_email": "john@example.com",
  "donor_phone": "+60123456789",
  "donor_address": "Kuala Lumpur",
  "amount": 500.00,
  "payment_method": "Card Payment",
  "payment_details": {
    "cardType": "Visa",
    "cardNumber": "****1234",
    "cardExpiry": "12/25"
  }
}
```

**Response:**
```json
{
  "success": true,
  "receipt_id": "DNR-ABC123DEF",
  "amount": 500.00,
  "goal_reached": false,
  "remaining_to_goal": 16050.00
}
```

#### GET `/api/my_donations.php?email=user@example.com`
Retrieve donation history for a user.

---

### Admin Endpoints

#### GET `/api/admin_campaigns.php`
Get all campaigns (including inactive).

#### POST `/api/admin_campaigns.php`
Create a new campaign.

#### PUT `/api/admin_campaigns.php`
Update an existing campaign.

#### DELETE `/api/admin_campaigns.php`
Delete/deactivate a campaign.

#### GET `/api/admin_donations.php`
Get all donations across the platform.

#### DELETE `/api/admin_donations.php`
Delete a donation and reverse campaign totals.

#### GET `/api/admin_support.php`
Get all support messages.

---

### Trustee Endpoints

#### GET `/api/trustee.php?ngo=NGO%20Name`
Get campaigns, history, and donations for a specific NGO.

---

### Support

#### POST `/api/support.php`
Submit a support ticket.

**Request Body:**
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "phone": "0123456789",
  "category": "Donation Issue",
  "message": "I need help with..."
}
```

---

## 📁 Folder Structure

```
donare-v/
├── api/                    # Backend PHP API endpoints
│   ├── admin_campaigns.php # Admin campaign CRUD
│   ├── admin_donations.php # Admin donation management
│   ├── admin_support.php   # Support ticket management
│   ├── campaigns.php       # Public campaign listing
│   ├── db.php              # Database connection
│   ├── donate.php          # Donation processing
│   ├── login.php           # User authentication
│   ├── logout.php          # Session termination
│   ├── my_donations.php    # User donation history
│   ├── ngo_history.php     # NGO transparency data
│   ├── signup.php          # User registration
│   ├── support.php         # Support ticket submission
│   ├── trustee.php         # Trustee dashboard data
│   └── upload_image.php    # Image upload handler
│
├── uploads/                # User-uploaded images
│
├── donare.html            # Main single-page application
├── main.js                # Frontend JavaScript logic
├── styles32.css           # Stylesheet
├── donare_db.sql          # Database schema and seed data
│
├── .env.example           # Environment variable template
├── .gitignore             # Git ignore rules
└── README.md              # Project documentation
```

---

## 👥 User Roles

| Role | Capabilities |
|------|-------------|
| **User** | Browse campaigns, make donations, view personal history |
| **Trustee** | All user capabilities + view NGO dashboard, campaign stats |
| **Admin** | Full access: manage campaigns, donations, support tickets |

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Code Style Guidelines

- Use 2-space indentation for HTML/CSS/JS
- Use 4-space indentation for PHP
- Follow PSR-12 coding standards for PHP
- Use meaningful variable and function names
- Comment complex logic

### Reporting Issues

Please use GitHub Issues to report bugs or request features. Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Donare

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 📞 Contact & Support

- **Project Repository:** [GitHub](https://github.com/yourusername/donare-v)
- **Issue Tracker:** [GitHub Issues](https://github.com/yourusername/donare-v/issues)
- **Email:** support@donare.org

---

<p align="center">
  Made with ❤️ for charitable giving
</p>
