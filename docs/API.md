# Donare API Documentation

This document provides detailed information about the Donare REST API endpoints.

## Base URL

```
/donare-v/api
```

## Authentication

Currently uses client-side session storage. Server-side JWT authentication is planned for future releases.

---

## Endpoints

### Authentication

#### Login
```http
POST /login.php
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

**Response (200):**
```json
{
  "success": true,
  "id": 1,
  "name": "User Name",
  "email": "user@example.com",
  "role": "user|trustee|admin",
  "ngo_name": "NGO Name (if trustee)"
}
```

**Error (401):**
```json
{
  "error": "Invalid email or password"
}
```

---

#### Signup
```http
POST /signup.php
```

**Request Body:**
```json
{
  "name": "New User",
  "email": "newuser@example.com",
  "password": "securepassword"
}
```

**Response (200):**
```json
{
  "success": true,
  "id": 1,
  "name": "New User",
  "email": "newuser@example.com",
  "role": "user"
}
```

---

#### Logout
```http
POST /logout.php
```

**Response (200):**
```json
{
  "success": true
}
```

---

### Campaigns

#### List Active Campaigns
```http
GET /campaigns.php
```

**Response (200):**
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
    "image_url": "uploads/img_abc123.jpg",
    "description": "...",
    "ngo": "WaterFirst NGO",
    "remaining_to_goal": 16550.00,
    "max_allowed_donation": 10000,
    "goal_reached": false,
    "transaction_limit": 10000
  }
]
```

---

### Donations

#### Process Donation
```http
POST /donate.php
```

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
  },
  "user_id": 1
}
```

**Response (200):**
```json
{
  "success": true,
  "receipt_id": "DNR-ABC123DEF",
  "amount": 500.00,
  "goal_reached": false,
  "remaining_to_goal": 16050.00
}
```

**Error Codes:**
- `EXCEEDS_TRANSACTION_LIMIT`: Amount exceeds ₹10,000 per transaction
- `GOAL_REACHED`: Campaign has already reached its funding goal
- `EXCEEDS_REMAINING_GOAL`: Amount exceeds remaining amount needed

---

#### Get User's Donation History
```http
GET /my_donations.php?email=user@example.com
```

**Response (200):**
```json
[
  {
    "id": 1,
    "receipt_id": "DNR-ABC123",
    "amount": 500.00,
    "status": "Completed",
    "donated_at": "2024-01-15 10:30:00",
    "campaign_title": "Clean Water Wells",
    "payment_method": "Card Payment"
  }
]
```

---

### Support

#### Submit Support Ticket
```http
POST /support.php
```

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

**Valid Categories:**
- General Enquiry
- Donation Issue
- Receipt / Tax
- Campaign Feedback
- Partnership
- Technical Problem
- Other

**Response (200):**
```json
{
  "success": true
}
```

---

### Trustee Endpoints

#### Get NGO Dashboard Data
```http
GET /trustee.php?ngo=NGO%20Name
GET /trustee.php?email=trustee@example.com
```

**Response (200):**
```json
{
  "campaigns": [...],
  "history": [...],
  "donations": [...]
}
```

---

### Admin Endpoints

#### Campaign Management
```http
GET /admin_campaigns.php
POST /admin_campaigns.php
PUT /admin_campaigns.php
DELETE /admin_campaigns.php
```

#### Donation Management
```http
GET /admin_donations.php
DELETE /admin_donations.php
```

#### Support Ticket Management
```http
GET /admin_support.php
POST /admin_support.php
```

---

## Error Responses

All endpoints return JSON errors in this format:

```json
{
  "error": "Error message describing what went wrong",
  "code": "OPTIONAL_ERROR_CODE",
  "detail": "Optional technical details (development only)"
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized |
| 404 | Not Found |
| 405 | Method Not Allowed |
| 500 | Internal Server Error |

---

## Rate Limiting

Currently no rate limiting implemented. Planned for future releases.

## CORS

All endpoints support CORS with the following settings:
- Allowed Origins: `*`
- Allowed Methods: `GET, POST, PUT, DELETE, OPTIONS`
- Allowed Headers: `Content-Type, Authorization, X-Requested-With`
