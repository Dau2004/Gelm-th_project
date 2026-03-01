# Database Viewing Guide - CMAM ML System

## Current Database: SQLite (Development)

Your system currently uses SQLite database located at:
- **Backend**: `gelmath_backend/db.sqlite3`
- **Mobile**: `cmam_mobile_app/[device storage]/cmam.db`

---

## Option 1: Django Admin Panel (Easiest)

### Access Web Interface

```bash
cd gelmath_backend
source venv/bin/activate  # On Windows: venv\Scripts\activate
python manage.py runserver
```

**Open browser:** http://localhost:8000/admin

**Login with:**
- Username: (your superuser)
- Password: (your password)

**If you don't have a superuser:**
```bash
python manage.py createsuperuser
# Enter username, email, password
```

**You can view:**
- All assessments
- Users
- Referrals
- Treatments
- Analytics data

---

## Option 2: DB Browser for SQLite (Visual Tool)

### Download & Install
- **Website**: https://sqlitebrowser.org/dl/
- **macOS**: `brew install --cask db-browser-for-sqlite`
- **Windows**: Download installer
- **Linux**: `sudo apt install sqlitebrowser`

### Steps:
1. Open DB Browser for SQLite
2. Click "Open Database"
3. Navigate to: `/Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_backend/db.sqlite3`
4. Browse tables:
   - `accounts_customuser` - Users
   - `assessments_assessment` - All assessments
   - `assessments_referral` - Referrals
   - `assessments_treatment` - Treatments

---

## Option 3: Command Line (SQLite CLI)

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_backend

# Open database
sqlite3 db.sqlite3

# View all tables
.tables

# View assessments
SELECT * FROM assessments_assessment LIMIT 10;

# Count assessments
SELECT COUNT(*) FROM assessments_assessment;

# View users
SELECT id, username, email, role, facility FROM accounts_customuser;

# View by clinical status
SELECT clinical_status, COUNT(*) as count 
FROM assessments_assessment 
GROUP BY clinical_status;

# View by pathway
SELECT recommended_pathway, COUNT(*) as count 
FROM assessments_assessment 
GROUP BY recommended_pathway;

# Exit
.quit
```

---

## Option 4: Python Script (Custom Queries)

Create a file: `view_database.py`

```python
import sqlite3
import pandas as pd

# Connect to database
conn = sqlite3.connect('db.sqlite3')

# View all assessments
df = pd.read_sql_query("SELECT * FROM assessments_assessment", conn)
print(f"\nTotal Assessments: {len(df)}")
print(df.head())

# View summary statistics
print("\n=== Clinical Status Distribution ===")
print(df['clinical_status'].value_counts())

print("\n=== Pathway Distribution ===")
print(df['recommended_pathway'].value_counts())

print("\n=== Age Distribution ===")
print(df['age_months'].describe())

print("\n=== MUAC Distribution ===")
print(df['muac_mm'].describe())

# View users
users = pd.read_sql_query("SELECT id, username, email, role, facility FROM accounts_customuser", conn)
print(f"\n=== Users ({len(users)}) ===")
print(users)

conn.close()
```

**Run:**
```bash
cd gelmath_backend
source venv/bin/activate
pip install pandas
python view_database.py
```

---

## Option 5: Django Shell (Interactive)

```bash
cd gelmath_backend
source venv/bin/activate
python manage.py shell
```

```python
# Import models
from assessments.models import Assessment
from accounts.models import CustomUser

# Count assessments
Assessment.objects.count()

# View all assessments
assessments = Assessment.objects.all()
for a in assessments[:5]:
    print(f"{a.child_id} - {a.clinical_status} - {a.recommended_pathway}")

# Filter by status
sam_cases = Assessment.objects.filter(clinical_status='SAM')
print(f"SAM cases: {sam_cases.count()}")

# View users
users = CustomUser.objects.all()
for u in users:
    print(f"{u.username} - {u.role} - {u.facility}")

# Get specific assessment
assessment = Assessment.objects.get(child_id='CMAM_001')
print(assessment.muac_mm, assessment.age_months)

# Exit
exit()
```

---

## Option 6: Export to CSV/Excel

### Using Django Management Command

Create: `gelmath_backend/assessments/management/commands/export_data.py`

```python
from django.core.management.base import BaseCommand
from assessments.models import Assessment
import csv

class Command(BaseCommand):
    help = 'Export assessments to CSV'

    def handle(self, *args, **kwargs):
        assessments = Assessment.objects.all()
        
        with open('assessments_export.csv', 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Child ID', 'Age', 'Sex', 'MUAC', 'Clinical Status', 
                'Pathway', 'Confidence', 'Date'
            ])
            
            for a in assessments:
                writer.writerow([
                    a.child_id, a.age_months, a.sex, a.muac_mm,
                    a.clinical_status, a.recommended_pathway,
                    a.confidence, a.created_at
                ])
        
        self.stdout.write(f'Exported {assessments.count()} assessments')
```

**Run:**
```bash
python manage.py export_data
# Opens: assessments_export.csv
```

---

## Quick Database Stats Script

Create: `db_stats.py`

```python
#!/usr/bin/env python3
import sqlite3

conn = sqlite3.connect('gelmath_backend/db.sqlite3')
cursor = conn.cursor()

print("=" * 50)
print("CMAM DATABASE STATISTICS")
print("=" * 50)

# Total assessments
cursor.execute("SELECT COUNT(*) FROM assessments_assessment")
print(f"\nTotal Assessments: {cursor.fetchone()[0]}")

# By clinical status
cursor.execute("""
    SELECT clinical_status, COUNT(*) 
    FROM assessments_assessment 
    GROUP BY clinical_status
""")
print("\nBy Clinical Status:")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

# By pathway
cursor.execute("""
    SELECT recommended_pathway, COUNT(*) 
    FROM assessments_assessment 
    GROUP BY recommended_pathway
""")
print("\nBy Pathway:")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

# By facility
cursor.execute("""
    SELECT facility, COUNT(*) 
    FROM assessments_assessment 
    WHERE facility IS NOT NULL
    GROUP BY facility
""")
print("\nBy Facility:")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

# Total users
cursor.execute("SELECT COUNT(*) FROM accounts_customuser")
print(f"\nTotal Users: {cursor.fetchone()[0]}")

# By role
cursor.execute("""
    SELECT role, COUNT(*) 
    FROM accounts_customuser 
    GROUP BY role
""")
print("\nBy Role:")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

conn.close()
```

**Run:**
```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT
python3 db_stats.py
```

---

## Mobile App Database (Android)

### View Mobile Database

**Option 1: Using Android Studio**
1. Open Android Studio
2. View → Tool Windows → Device File Explorer
3. Navigate to: `/data/data/com.example.cmam_app/databases/cmam.db`
4. Download file
5. Open with DB Browser for SQLite

**Option 2: Using ADB**
```bash
# Connect device
adb devices

# Pull database
adb pull /data/data/com.example.cmam_app/databases/cmam.db

# View with sqlite3
sqlite3 cmam.db
.tables
SELECT * FROM assessments;
```

---

## Recommended: Django Admin Panel

**Best for:**
- Quick viewing
- Editing data
- User-friendly interface
- No additional tools needed

**Steps:**
```bash
cd gelmath_backend
source venv/bin/activate
python manage.py runserver
```

Open: http://localhost:8000/admin

---

## Database Schema

### Main Tables

**assessments_assessment**
- id, child_id, sex, age_months, muac_mm
- edema, appetite, danger_signs
- muac_z_score, clinical_status
- recommended_pathway, confidence
- created_at, updated_at

**accounts_customuser**
- id, username, email, password
- role, facility, state, county
- phone, is_active, date_joined

**assessments_referral**
- id, assessment_id, child_id
- pathway, status, notes
- created_at, updated_at

**assessments_treatment**
- id, assessment_id, treatment_type
- start_date, end_date, notes

---

## Need Help?

Choose based on your preference:
1. **Visual Interface**: Django Admin or DB Browser
2. **Command Line**: SQLite CLI or Django Shell
3. **Data Analysis**: Python script with pandas
4. **Export**: CSV export for Excel

**Recommended: Start with Django Admin Panel** - It's the easiest and most user-friendly option!
