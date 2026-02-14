# Complete Backup and Restore Guide

## Quick Backup (Run This Now!)

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT

# Create backup directory with timestamp
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup database (MOST IMPORTANT)
cp gelmath_backend/db.sqlite3 "$BACKUP_DIR/"

# Backup all code
cp -r gelmath_backend "$BACKUP_DIR/"
cp -r gelmath_web "$BACKUP_DIR/"
cp -r cmam_mobile_app "$BACKUP_DIR/"

# Backup documentation
cp *.md "$BACKUP_DIR/"

echo "✅ Backup complete in $BACKUP_DIR"
```

## What Gets Backed Up

### 1. Database (CRITICAL)
- **File**: `gelmath_backend/db.sqlite3`
- **Contains**: 57+ assessments, users, facilities, referrals
- **Size**: ~200KB

### 2. Backend Code
- `gelmath_backend/assessments/` - Models, views, serializers, analytics
- `gelmath_backend/accounts/` - User management, authentication
- `gelmath_backend/gelmath_api/` - URL configuration

### 3. Web Dashboard
- `gelmath_web/src/pages/MoHDashboard.js` - Main dashboard with live data
- `gelmath_web/src/pages/DoctorDashboard.js` - Doctor interface
- `gelmath_web/src/services/api.js` - API integration
- `gelmath_web/src/components/UserModal.js` - User creation

### 4. Mobile App
- `cmam_mobile_app/lib/services/` - API, Auth, Sync services
- `cmam_mobile_app/lib/screens/` - Doctor selection, medical documents

## Restore Instructions

### If Database Gets Lost:
```bash
# Restore from backup
cp backup_YYYYMMDD_HHMMSS/db.sqlite3 gelmath_backend/
```

### If Code Gets Lost:
```bash
# Restore entire project
cp -r backup_YYYYMMDD_HHMMSS/* .
```

### If Starting Fresh:
```bash
# 1. Restore database
cp backup_YYYYMMDD_HHMMSS/db.sqlite3 gelmath_backend/

# 2. Install dependencies
cd gelmath_backend && pip install -r requirements.txt
cd ../gelmath_web && npm install
cd ../cmam_mobile_app && flutter pub get

# 3. Start services
cd gelmath_backend && python manage.py runserver 8000
cd gelmath_web && npm start
```

## Critical Files to Never Lose

1. **gelmath_backend/db.sqlite3** - All your data
2. **gelmath_backend/assessments/analytics_views.py** - Analytics endpoints
3. **gelmath_web/src/pages/MoHDashboard.js** - Dashboard with live data
4. **gelmath_web/src/services/api.js** - API integration
5. **cmam_mobile_app/lib/services/sync_service.dart** - Sync logic

## Git Backup (Recommended)

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT

# Initialize git if not already done
git init

# Add all files
git add .

# Commit with timestamp
git commit -m "Backup: Complete working system $(date +%Y-%m-%d)"

# Optional: Push to GitHub
# git remote add origin YOUR_GITHUB_URL
# git push -u origin main
```

## Cloud Backup Options

### Option 1: Google Drive
```bash
# Copy backup folder to Google Drive
cp -r backup_* ~/Google\ Drive/
```

### Option 2: Dropbox
```bash
# Copy backup folder to Dropbox
cp -r backup_* ~/Dropbox/
```

### Option 3: USB Drive
```bash
# Copy to USB drive
cp -r backup_* /Volumes/YOUR_USB_DRIVE/
```

## Verification Checklist

After backup, verify:
- [ ] Database file exists and is not empty (should be ~200KB)
- [ ] All Python files in gelmath_backend are backed up
- [ ] All JavaScript files in gelmath_web are backed up
- [ ] All Dart files in cmam_mobile_app are backed up
- [ ] Documentation files (*.md) are backed up

## Quick Restore Test

```bash
# Test that backup is valid
cd backup_YYYYMMDD_HHMMSS
sqlite3 db.sqlite3 "SELECT COUNT(*) FROM assessments_assessment;"
# Should show: 57 (or your current count)
```

## Emergency Recovery

If everything breaks tomorrow:

1. **Find your backup folder**: `backup_YYYYMMDD_HHMMSS`
2. **Copy database**: `cp backup_*/db.sqlite3 gelmath_backend/`
3. **Start backend**: `cd gelmath_backend && python manage.py runserver 8000`
4. **Start dashboard**: `cd gelmath_web && npm start`
5. **Login**: Use doctor1/doctor123 or moh_admin/admin123

## What to Do Tomorrow

1. Run the backup script above
2. Verify backup folder was created
3. Check database file size (~200KB)
4. Continue working with confidence!

## Backup Schedule

- **Daily**: Run backup script before starting work
- **After major changes**: Create new backup
- **Before updates**: Always backup first

## Contact Info for Recovery

If you need help recovering:
1. Check this file first
2. Look for backup_* folders
3. Database is in gelmath_backend/db.sqlite3
4. All code is in gelmath_backend/, gelmath_web/, cmam_mobile_app/

---

**IMPORTANT**: Run the backup script at the top of this file RIGHT NOW before doing anything else!
