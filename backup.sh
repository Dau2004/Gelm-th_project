#!/bin/bash

# Automated Backup Script for MUAC Development Project
# Run this daily to backup all your work

set -e  # Exit on error

PROJECT_DIR="/Users/ram/Downloads/MUAC_DEVELOPMENT"
BACKUP_BASE="$PROJECT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/backup_$TIMESTAMP"

echo "🔄 Starting backup..."
echo "📁 Backup location: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# 1. Backup database (MOST CRITICAL)
echo "💾 Backing up database..."
if [ -f "$PROJECT_DIR/gelmath_backend/db.sqlite3" ]; then
    cp "$PROJECT_DIR/gelmath_backend/db.sqlite3" "$BACKUP_DIR/"
    DB_SIZE=$(du -h "$PROJECT_DIR/gelmath_backend/db.sqlite3" | cut -f1)
    echo "   ✅ Database backed up ($DB_SIZE)"
else
    echo "   ⚠️  Database not found!"
fi

# 2. Backup backend code
echo "🐍 Backing up backend..."
cp -r "$PROJECT_DIR/gelmath_backend" "$BACKUP_DIR/"
echo "   ✅ Backend code backed up"

# 3. Backup web dashboard
echo "🌐 Backing up web dashboard..."
cp -r "$PROJECT_DIR/gelmath_web" "$BACKUP_DIR/"
echo "   ✅ Web dashboard backed up"

# 4. Backup mobile app
echo "📱 Backing up mobile app..."
cp -r "$PROJECT_DIR/cmam_mobile_app" "$BACKUP_DIR/"
echo "   ✅ Mobile app backed up"

# 5. Backup documentation
echo "📄 Backing up documentation..."
cp "$PROJECT_DIR"/*.md "$BACKUP_DIR/" 2>/dev/null || true
echo "   ✅ Documentation backed up"

# 6. Create backup info file
cat > "$BACKUP_DIR/BACKUP_INFO.txt" << EOF
Backup Created: $(date)
Backup Location: $BACKUP_DIR

Contents:
- Database: db.sqlite3
- Backend: gelmath_backend/
- Web Dashboard: gelmath_web/
- Mobile App: cmam_mobile_app/
- Documentation: *.md files

To Restore:
1. Copy db.sqlite3 to gelmath_backend/
2. Copy code folders as needed
3. Run: cd gelmath_backend && python manage.py runserver 8000
4. Run: cd gelmath_web && npm start

Database Stats:
EOF

# Add database stats if available
if [ -f "$BACKUP_DIR/db.sqlite3" ]; then
    sqlite3 "$BACKUP_DIR/db.sqlite3" "SELECT '- Assessments: ' || COUNT(*) FROM assessments_assessment;" >> "$BACKUP_DIR/BACKUP_INFO.txt" 2>/dev/null || echo "- Assessments: N/A" >> "$BACKUP_DIR/BACKUP_INFO.txt"
    sqlite3 "$BACKUP_DIR/db.sqlite3" "SELECT '- Users: ' || COUNT(*) FROM accounts_user;" >> "$BACKUP_DIR/BACKUP_INFO.txt" 2>/dev/null || echo "- Users: N/A" >> "$BACKUP_DIR/BACKUP_INFO.txt"
    sqlite3 "$BACKUP_DIR/db.sqlite3" "SELECT '- Facilities: ' || COUNT(*) FROM assessments_facility;" >> "$BACKUP_DIR/BACKUP_INFO.txt" 2>/dev/null || echo "- Facilities: N/A" >> "$BACKUP_DIR/BACKUP_INFO.txt"
    sqlite3 "$BACKUP_DIR/db.sqlite3" "SELECT '- Referrals: ' || COUNT(*) FROM assessments_referral;" >> "$BACKUP_DIR/BACKUP_INFO.txt" 2>/dev/null || echo "- Referrals: N/A" >> "$BACKUP_DIR/BACKUP_INFO.txt"
fi

# 7. Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo ""
echo "✅ Backup complete!"
echo "📊 Total size: $BACKUP_SIZE"
echo "📁 Location: $BACKUP_DIR"

# 8. Clean up old backups (keep last 7 days)
echo ""
echo "🧹 Cleaning old backups (keeping last 7)..."
cd "$BACKUP_BASE"
ls -t | tail -n +8 | xargs rm -rf 2>/dev/null || true
REMAINING=$(ls -1 | wc -l)
echo "   ✅ $REMAINING backups remaining"

# 9. Create latest symlink
rm -f "$BACKUP_BASE/latest"
ln -s "$BACKUP_DIR" "$BACKUP_BASE/latest"

echo ""
echo "🎉 All done! Your work is safe."
echo ""
echo "Quick restore: cp backups/latest/db.sqlite3 gelmath_backend/"
