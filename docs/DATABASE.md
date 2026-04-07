# Donare Database Documentation

This document describes the database schema for the Donare donation platform.

## Database Overview

- **Database Name:** `donare_db`
- **Character Set:** `utf8mb4`
- **Collation:** `utf8mb4_unicode_ci`

---

## Entity Relationship Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    users    │     │   admins    │     │  trustees   │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id (PK)     │     │ id (PK)     │     │ id (PK)     │
│ name        │     │ name        │     │ name        │
│ email       │     │ email       │     │ email       │
│ password    │     │ password    │     │ password    │
│ role        │     │ created_at  │     │ ngo_name    │
│ created_at  │     └─────────────┘     │ created_at  │
└─────────────┘                         └─────────────┘
                                               │
                                               │ (ngo_name)
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│    ngos     │────<│  campaigns  │────<│   donations     │
├─────────────┤     ├─────────────┤     ├─────────────────┤
│ id (PK)     │     │ id (PK)     │     │ id (PK)         │
│ name        │     │ title       │     │ receipt_id (UQ) │
│ description │     │ ngo_id (FK) │     │ campaign_id (FK)│
│ created_at  │     │ category    │     │ user_id (FK)    │
└─────────────┘     │ goal        │     │ donor_name      │
       │            │ raised      │     │ donor_email     │
       │            │ donors      │     │ amount          │
       ▼            │ days_left   │     │ status          │
┌─────────────┐     │ image_url   │     │ donated_at      │
│ ngo_history │     │ description │     └─────────────────┘
├─────────────┤     │ is_active   │
│ id (PK)     │     │ max_donation│
│ ngo_id (FK) │     └─────────────┘
│ year        │
│ title       │     ┌─────────────────┐
│ raised      │     │support_messages │
│ distributed │     ├─────────────────┤
│ beneficiaries│    │ id (PK)         │
│ period      │     │ name            │
│ note        │     │ email           │
└─────────────┘     │ phone           │
                    │ category        │
                    │ message         │
                    │ status          │
                    │ submitted_at    │
                    │ resolved_at     │
                    └─────────────────┘
```

---

## Tables

### users

Stores regular donor user accounts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | User's display name |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Login email |
| password | VARCHAR(255) | NOT NULL | Bcrypt hashed password |
| role | VARCHAR(20) | DEFAULT 'user' | User role |
| ngo_name | VARCHAR(255) | NULL | Associated NGO (if any) |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time |

### admins

Stores administrator accounts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Admin's display name |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Login email |
| password | VARCHAR(255) | NOT NULL | Bcrypt hashed password |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time |

### trustees

Stores NGO trustee accounts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Trustee's display name |
| email | VARCHAR(255) | NOT NULL, UNIQUE | Login email |
| password | VARCHAR(255) | NOT NULL | Bcrypt hashed password |
| ngo_name | VARCHAR(255) | NOT NULL | Associated NGO name |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time |

### ngos

Stores registered NGO/charity organizations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(255) | NOT NULL, UNIQUE | NGO name |
| description | TEXT | NULL | Organization description |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Registration time |

### campaigns

Stores fundraising campaigns.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| title | VARCHAR(255) | NOT NULL | Campaign title |
| ngo_id | INT | FOREIGN KEY (ngos.id) | Associated NGO |
| category | VARCHAR(50) | NOT NULL | Campaign category |
| goal | DECIMAL(12,2) | NOT NULL | Funding goal amount |
| raised | DECIMAL(12,2) | DEFAULT 0 | Amount raised so far |
| donors | INT | DEFAULT 0 | Number of donors |
| days_left | INT | DEFAULT 30 | Days until campaign ends |
| image_url | VARCHAR(500) | NULL | Campaign image URL |
| description | TEXT | NULL | Campaign description |
| is_active | TINYINT(1) | DEFAULT 1 | Active status flag |
| max_donation | DECIMAL(12,2) | NULL | Maximum donation per user |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |

**Categories:** Education, Environment, Humanitarian, Energy, Health

### donations

Stores donation transaction records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| receipt_id | VARCHAR(50) | UNIQUE | Receipt number (DNR-xxx) |
| user_id | INT | FOREIGN KEY (users.id), NULL | Registered donor (optional) |
| campaign_id | INT | FOREIGN KEY (campaigns.id) | Target campaign |
| donor_name | VARCHAR(100) | NOT NULL | Donor's name |
| donor_email | VARCHAR(255) | NOT NULL | Donor's email |
| donor_phone | VARCHAR(30) | NULL | Donor's phone |
| donor_address | TEXT | NULL | Donor's address |
| amount | DECIMAL(12,2) | NOT NULL | Donation amount |
| payment_method | VARCHAR(30) | NULL | Payment method used |
| payment_details | TEXT | NULL | JSON payment details |
| status | VARCHAR(20) | DEFAULT 'Completed' | Transaction status |
| donated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Transaction time |

### ngo_history

Stores historical transparency data for NGOs.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| ngo_id | INT | FOREIGN KEY (ngos.id) | Associated NGO |
| year | INT | NOT NULL | Record year |
| title | VARCHAR(255) | NOT NULL | Historical campaign title |
| raised | DECIMAL(12,2) | DEFAULT 0 | Amount raised |
| distributed | DECIMAL(12,2) | DEFAULT 0 | Amount distributed |
| beneficiaries | INT | DEFAULT 0 | Number of beneficiaries |
| period | VARCHAR(50) | NULL | Campaign period |
| note | TEXT | NULL | Additional notes |

### support_messages

Stores user support tickets.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Sender's name |
| email | VARCHAR(255) | NOT NULL | Sender's email |
| phone | VARCHAR(30) | NOT NULL | Sender's phone |
| category | VARCHAR(50) | NOT NULL | Ticket category |
| message | TEXT | NOT NULL | Message content |
| status | VARCHAR(20) | DEFAULT 'Pending' | Ticket status |
| submitted_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Submission time |
| resolved_at | DATETIME | NULL | Resolution time |

---

## Indexes

### Primary Keys
- All tables have auto-incrementing `id` as primary key

### Unique Indexes
- `users.email`
- `admins.email`
- `trustees.email`
- `ngos.name`
- `donations.receipt_id`

### Foreign Keys
- `campaigns.ngo_id` → `ngos.id`
- `donations.campaign_id` → `campaigns.id`
- `donations.user_id` → `users.id`
- `ngo_history.ngo_id` → `ngos.id`

---

## Migrations

Database migrations are stored in `database/migrations/`. To add a new migration:

1. Create a new file with timestamp prefix: `YYYYMMDD_HHMMSS_description.sql`
2. Include both `UP` and `DOWN` statements
3. Test on development before applying to production

---

## Backup & Restore

### Backup
```bash
mysqldump -u root -p donare_db > backup_$(date +%Y%m%d).sql
```

### Restore
```bash
mysql -u root -p donare_db < backup_20240115.sql
```
