# PostgreSQL Database Viewing Guide - CMAM ML System

## Setup Local PostgreSQL (Development)

### Install PostgreSQL

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**Windows:**
- Download: https://www.postgresql.org/download/windows/
- Install PostgreSQL 15
- Remember password for postgres user

**Linux:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

---

## Configure Django to Use PostgreSQL

### 1. Install PostgreSQL Driver

```bash
cd gelmath_backend
source venv/bin/activate
pip install psycopg2-binary
```

### 2. Create Database

```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE cmam_db;

# Create user
CREATE USER cmam_admin WITH PASSWORD 'your_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE cmam_db TO cmam_admin;

# Exit
\q
```

### 3. Update Django Settings

Edit `gelmath_backend/gelmath_project/settings.py`:

```python
# Replace SQLite configuration with PostgreSQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'cmam_db',
        'USER': 'cmam_admin',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### 4. Migrate Data

```bash
cd gelmath_backend
source venv/bin/activate

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Load sample data (optional)
python seed_data.py
```

---

## View PostgreSQL Database

### Option 1: pgAdmin (Best GUI Tool)

**Download:** https://www.pgadmin.org/download/

**Steps:**
1. Install pgAdmin
2. Open pgAdmin
3. Right-click "Servers" → Register → Server
4. General tab:
   - Name: CMAM Local
5. Connection tab:
   - Host: localhost
   - Port: 5432
   - Database: cmam_db
   - Username: cmam_admin
   - Password: your_password
6. Save

**Browse:**
- Servers → CMAM Local → Databases → cmam_db → Schemas → public → Tables
- Right-click table → View/Edit Data → All Rows

---

### Option 2: psql Command Line

```bash
# Connect to database
psql -U cmam_admin -d cmam_db

# List all tables
\dt

# View assessments
SELECT * FROM assessments_assessment LIMIT 10;

# Count assessments
SELECT COUNT(*) FROM assessments_assessment;

# View by clinical status
SELECT clinical_status, COUNT(*) 
FROM assessments_assessment 
GROUP BY clinical_status;

# View by pathway
SELECT recommended_pathway, COUNT(*) 
FROM assessments_assessment 
GROUP BY recommended_pathway;

# View users
SELECT id, username, email, role, facility 
FROM accounts_customuser;

# Describe table structure
\d assessments_assessment

# Exit
\q
```

---

### Option 3: DBeaver (Universal Database Tool)

**Download:** https://dbeaver.io/download/

**Steps:**
1. Install DBeaver
2. New Database Connection → PostgreSQL
3. Connection Settings:
   - Host: localhost
   - Port: 5432
   - Database: cmam_db
   - Username: cmam_admin
   - Password: your_password
4. Test Connection → Finish

**Features:**
- Visual query builder
- ER diagrams
- Data export (CSV, Excel, JSON)
- SQL editor with autocomplete

---

### Option 4: Django Admin Panel

```bash
cd gelmath_backend
source venv/bin/activate
python manage.py runserver
```

Open: http://localhost:8000/admin

**Same interface, different database backend!**

---

### Option 5: TablePlus (Modern GUI)

**Download:** https://tableplus.com/

**Steps:**
1. Install TablePlus
2. Create new connection → PostgreSQL
3. Connection info:
   - Host: localhost
   - Port: 5432
   - User: cmam_admin
   - Password: your_password
   - Database: cmam_db
4. Connect

**Features:**
- Clean, modern interface
- Fast performance
- Multi-tab support
- Query history

---

## Useful PostgreSQL Queries

### Database Statistics

```sql
-- Total assessments
SELECT COUNT(*) as total_assessments 
FROM assessments_assessment;

-- By clinical status
SELECT 
    clinical_status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM assessments_assessment
GROUP BY clinical_status
ORDER BY count DESC;

-- By pathway
SELECT 
    recommended_pathway,
    COUNT(*) as count
FROM assessments_assessment
GROUP BY recommended_pathway
ORDER BY count DESC;

-- By facility
SELECT 
    facility,
    COUNT(*) as assessments,
    COUNT(DISTINCT child_id) as unique_children
FROM assessments_assessment
WHERE facility IS NOT NULL
GROUP BY facility
ORDER BY assessments DESC;

-- Recent assessments
SELECT 
    child_id,
    age_months,
    muac_mm,
    clinical_status,
    recommended_pathway,
    created_at
FROM assessments_assessment
ORDER BY created_at DESC
LIMIT 20;

-- Average MUAC by age group
SELECT 
    CASE 
        WHEN age_months BETWEEN 6 AND 11 THEN '6-11 months'
        WHEN age_months BETWEEN 12 AND 23 THEN '12-23 months'
        WHEN age_months BETWEEN 24 AND 35 THEN '24-35 months'
        WHEN age_months BETWEEN 36 AND 47 THEN '36-47 months'
        ELSE '48-59 months'
    END as age_group,
    COUNT(*) as count,
    ROUND(AVG(muac_mm), 1) as avg_muac,
    ROUND(MIN(muac_mm), 1) as min_muac,
    ROUND(MAX(muac_mm), 1) as max_muac
FROM assessments_assessment
GROUP BY age_group
ORDER BY age_group;

-- Users by role
SELECT 
    role,
    COUNT(*) as count,
    COUNT(CASE WHEN is_active THEN 1 END) as active
FROM accounts_customuser
GROUP BY role;
```

---

## Export Data from PostgreSQL

### Export to CSV

```bash
# Export assessments
psql -U cmam_admin -d cmam_db -c "\COPY (SELECT * FROM assessments_assessment) TO 'assessments.csv' CSV HEADER"

# Export users
psql -U cmam_admin -d cmam_db -c "\COPY (SELECT id, username, email, role, facility FROM accounts_customuser) TO 'users.csv' CSV HEADER"

# Export summary
psql -U cmam_admin -d cmam_db -c "\COPY (SELECT clinical_status, COUNT(*) FROM assessments_assessment GROUP BY clinical_status) TO 'summary.csv' CSV HEADER"
```

### Backup Database

```bash
# Full backup
pg_dump -U cmam_admin -d cmam_db -F c -f cmam_backup.dump

# SQL format backup
pg_dump -U cmam_admin -d cmam_db > cmam_backup.sql

# Restore from backup
pg_restore -U cmam_admin -d cmam_db cmam_backup.dump
```

---

## Connect to AWS RDS PostgreSQL

### From Local Machine

```bash
# Install PostgreSQL client
brew install libpq  # macOS
sudo apt install postgresql-client  # Linux

# Connect to RDS
psql -h your-rds-endpoint.rds.amazonaws.com -U cmam_admin -d cmam_db

# Example
psql -h cmam-db.c9akciq32.us-east-1.rds.amazonaws.com -U cmam_admin -d cmam_db
```

### Using pgAdmin

1. Create new server connection
2. Connection settings:
   - Host: your-rds-endpoint.rds.amazonaws.com
   - Port: 5432
   - Database: cmam_db
   - Username: cmam_admin
   - Password: [your RDS password]
3. SSL: Prefer (or Require for production)

---

## Python Script to View Data

Create: `view_postgres.py`

```python
import psycopg2
import pandas as pd

# Connection parameters
conn = psycopg2.connect(
    host="localhost",
    database="cmam_db",
    user="cmam_admin",
    password="your_password"
)

# View assessments
df = pd.read_sql_query("SELECT * FROM assessments_assessment", conn)
print(f"\nTotal Assessments: {len(df)}")
print(df.head())

# Summary statistics
print("\n=== Clinical Status Distribution ===")
status_df = pd.read_sql_query("""
    SELECT clinical_status, COUNT(*) as count
    FROM assessments_assessment
    GROUP BY clinical_status
""", conn)
print(status_df)

print("\n=== Pathway Distribution ===")
pathway_df = pd.read_sql_query("""
    SELECT recommended_pathway, COUNT(*) as count
    FROM assessments_assessment
    GROUP BY recommended_pathway
""", conn)
print(pathway_df)

# Users
users_df = pd.read_sql_query("""
    SELECT id, username, email, role, facility
    FROM accounts_customuser
""", conn)
print(f"\n=== Users ({len(users_df)}) ===")
print(users_df)

conn.close()
```

**Run:**
```bash
pip install psycopg2-binary pandas
python view_postgres.py
```

---

## Database Monitoring

### Check Database Size

```sql
SELECT 
    pg_size_pretty(pg_database_size('cmam_db')) as database_size;
```

### Check Table Sizes

```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Active Connections

```sql
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state
FROM pg_stat_activity
WHERE datname = 'cmam_db';
```

---

## Recommended Tools by Use Case

| Use Case | Tool | Why |
|----------|------|-----|
| **Quick View** | Django Admin | Already integrated |
| **Data Analysis** | pgAdmin | Full-featured, free |
| **Modern UI** | TablePlus | Beautiful, fast |
| **Universal** | DBeaver | Works with all databases |
| **Command Line** | psql | Fast, scriptable |
| **Python Scripts** | psycopg2 + pandas | Automation |

---

## Quick Setup Script

Create: `setup_postgres.sh`

```bash
#!/bin/bash

# Create database and user
psql -U postgres <<EOF
CREATE DATABASE cmam_db;
CREATE USER cmam_admin WITH PASSWORD 'cmam2024';
GRANT ALL PRIVILEGES ON DATABASE cmam_db TO cmam_admin;
\q
EOF

# Run Django migrations
cd gelmath_backend
source venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
python seed_data.py

echo "PostgreSQL setup complete!"
echo "Connect: psql -U cmam_admin -d cmam_db"
```

**Run:**
```bash
chmod +x setup_postgres.sh
./setup_postgres.sh
```

---

## Troubleshooting

### Can't connect to PostgreSQL

```bash
# Check if PostgreSQL is running
brew services list  # macOS
sudo systemctl status postgresql  # Linux

# Start PostgreSQL
brew services start postgresql@15  # macOS
sudo systemctl start postgresql  # Linux
```

### Authentication failed

```bash
# Edit pg_hba.conf
sudo nano /usr/local/var/postgresql@15/pg_hba.conf  # macOS
sudo nano /etc/postgresql/15/main/pg_hba.conf  # Linux

# Change to:
local   all   all   trust
host    all   all   127.0.0.1/32   trust

# Restart PostgreSQL
brew services restart postgresql@15
```

### Reset password

```bash
psql -U postgres
ALTER USER cmam_admin WITH PASSWORD 'new_password';
\q
```

---

## Best Practice: Use pgAdmin

**Why pgAdmin?**
- Free and open-source
- Full-featured
- Works with local and remote databases
- Visual query builder
- Backup/restore tools
- ER diagrams

**Download:** https://www.pgadmin.org/download/

This is the industry standard for PostgreSQL management!
