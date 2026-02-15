# 📦 GitHub Push Guide - CMAM ML System

## ✅ Essential Files/Folders to Push

### 📂 **Core Folders** (MUST PUSH)

```
MUAC_DEVELOPMENT/
├── 📂 Dataset/                              ✅ PUSH
│   ├── CMAM guidelines south sudan 2017.pdf
│   ├── cmam_4000_clean_data.csv            (Main training data)
│   ├── quality_train_20260209_220137.csv
│   ├── quality_val_20260209_220137.csv
│   └── quality_test_20260209_220137.csv
│
├── 📂 Models/                               ✅ PUSH
│   ├── cmam_model.pkl                      (Model 1)
│   ├── model2_quality_classifier.pkl       (Model 2)
│   ├── cmam_model_metadata.json
│   └── model2_metadata.json
│
├── 📂 Notebooks/                            ✅ PUSH
│   ├── model_training.ipynb
│   ├── model2_quality_training.ipynb
│   ├── cmam_cleaning_visualization.ipynb
│   └── Image_data_visualization.ipynb
│
├── 📂 cmam_mobile_app/                      ✅ PUSH
│   ├── lib/                                (All source code)
│   ├── assets/                             (Images, LMS tables)
│   ├── android/                            (Config files only)
│   ├── ios/                                (Config files only)
│   ├── pubspec.yaml
│   ├── README.md
│   └── .gitignore
│
├── 📂 cmam_backend/                         ✅ PUSH
│   ├── assessments/                        (All app code)
│   ├── analytics/
│   ├── users/
│   ├── referrals/
│   ├── cmam_project/
│   ├── manage.py
│   ├── requirements.txt
│   ├── model2_quality_classifier.pkl
│   └── README.md
│
├── 📂 gelmath_backend/                      ✅ PUSH
│   ├── accounts/                           (All app code)
│   ├── analytics/
│   ├── assessments/
│   ├── gelmath_api/
│   ├── manage.py
│   ├── requirements.txt
│   ├── seed_data.py
│   └── README.md
│
├── 📂 gelmath_web/                          ✅ PUSH
│   ├── src/                                (All React code)
│   ├── public/
│   ├── package.json
│   └── .gitignore
│
├── 📂 Screenshot/                           ✅ PUSH
│   ├── Login_mobileapp.png
│   ├── Home_mobileapp.png
│   ├── Assessment_mobileapp.png
│   ├── result_mobileapp.png
│   ├── History_mobileapp.png
│   ├── Doctordasboard.png
│   ├── MoH_Overview.png
│   ├── MoH_analytics.png
│   └── MoH_Usersmanagement.png
│
├── 📂 WHO_Table/                            ✅ PUSH
│   ├── acfa-boys-3-5-zscores.xlsx
│   └── acfa-girls-3-5-zscores.xlsx
│
├── 📄 README.md                             ✅ PUSH (Main documentation)
├── 📄 ASSIGNMENT_ASSESSMENT.md              ✅ PUSH
├── 📄 SUBMISSION_CHECKLIST.md               ✅ PUSH
├── 📄 requirements.txt                      ✅ PUSH
├── 📄 .gitignore                            ✅ PUSH
└── 📄 LICENSE                               ✅ PUSH (if exists)
```

---

## ❌ Files/Folders to EXCLUDE (Already in .gitignore)

### 🗑️ **DO NOT PUSH**

```
❌ backups/                    (All backup folders)
❌ db.sqlite3                  (Database files)
❌ *.log                       (Log files)
❌ __pycache__/                (Python cache)
❌ node_modules/               (Node dependencies)
❌ .dart_tool/                 (Dart build cache)
❌ build/                      (Build artifacts)
❌ venv/                       (Virtual environments)
❌ .env                        (Environment variables)
❌ *.pyc                       (Compiled Python)
❌ .DS_Store                   (Mac OS files)
❌ .idea/                      (IDE settings)
❌ .vscode/                    (IDE settings)

❌ Intermediate data files:
   - cmam_gold_*.csv
   - cmam_realistic_*.csv
   - train_*.csv
   - val_*.csv
   - test_*.csv
   - *_clean_*.csv

❌ Debug/Fix documentation:
   - BACKUP_AND_RESTORE.md
   - CONNECTION_GUIDE.md
   - QUICK_FIX_GUIDE.md
   - All *_FIX.md files
   - All *_COMPLETE.md files

❌ Test scripts:
   - backup.sh
   - test_*.sh
   - test_*.py
   - setup_test_users.py
```

---

## 🚀 Step-by-Step Push Instructions

### 1️⃣ Initialize Git Repository

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT

# Initialize git (if not already done)
git init

# Add the .gitignore file
git add .gitignore
git commit -m "Add .gitignore file"
```

### 2️⃣ Add Essential Files

```bash
# Add all essential folders
git add Dataset/
git add Models/
git add Notebooks/
git add cmam_mobile_app/
git add cmam_backend/
git add gelmath_backend/
git add gelmath_web/
git add Screenshot/
git add WHO_Table/

# Add documentation
git add README.md
git add ASSIGNMENT_ASSESSMENT.md
git add SUBMISSION_CHECKLIST.md
git add requirements.txt

# Check what will be committed
git status
```

### 3️⃣ Commit Changes

```bash
git commit -m "Initial commit: CMAM ML System v1.0

- Add ML models (pathway classifier + quality checker)
- Add mobile app (Flutter)
- Add web dashboards (React)
- Add backend APIs (Django - cmam_backend + gelmath_backend)
- Add training notebooks
- Add datasets and documentation
"
```

### 4️⃣ Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `CMAM_ML_System`
3. Description: `AI-powered malnutrition screening system based on WHO guidelines`
4. Choose: **Public** (for portfolio) or **Private**
5. **DO NOT** initialize with README (you already have one)
6. Click "Create repository"

### 5️⃣ Push to GitHub

```bash
# Add remote repository (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/CMAM_ML_System.git

# Push to main branch
git branch -M main
git push -u origin main
```

---

## 📊 Repository Size Estimate

```
Essential files only:
├── Source code:        ~50 MB
├── Models (.pkl):      ~10 MB
├── Datasets (.csv):    ~5 MB
├── Screenshots:        ~3 MB
├── Documentation:      ~2 MB
├── WHO tables:         ~1 MB
└── CMAM PDF:          ~5 MB
─────────────────────────────
Total:                 ~76 MB ✅ (Well within GitHub limits)
```

**Note**: GitHub has a 100 MB file size limit and recommends repositories under 1 GB.

---

## 🔍 Verify Before Pushing

```bash
# Check repository size
du -sh .git

# List all files to be committed
git ls-files

# Check for large files (>50MB)
find . -type f -size +50M

# Verify .gitignore is working
git status --ignored
```

---

## 📝 Recommended GitHub Repository Settings

### Repository Description
```
🏥 AI-powered malnutrition screening system for children (6-59 months) 
based on WHO guidelines and South Sudan CMAM 2017 standards. 
Features: ML models (94% accuracy), Flutter mobile app, React dashboard, Django API.
```

### Topics/Tags
```
machine-learning
healthcare
malnutrition
flutter
react
django
who-guidelines
cmam
random-forest
mobile-app
```

### README Badges (already in your README.md)
- ✅ License: MIT
- ✅ Python 3.13+
- ✅ Flutter 3.0+
- ✅ React 19.2+

---

## 🎯 Post-Push Checklist

After pushing to GitHub:

- [ ] Verify all essential files are visible on GitHub
- [ ] Check that `.gitignore` is working (no db.sqlite3, no backups/)
- [ ] Test clone on another machine: `git clone https://github.com/YOUR_USERNAME/CMAM_ML_System.git`
- [ ] Add repository link to your README.md
- [ ] Enable GitHub Pages (optional) for documentation
- [ ] Add collaborators (if team project)
- [ ] Create releases/tags for versions

---

## 🔄 Future Updates

When making changes:

```bash
# Check status
git status

# Add specific files
git add path/to/file

# Commit with descriptive message
git commit -m "Fix: Description of changes"

# Push to GitHub
git push origin main
```

---

## ⚠️ Important Notes

1. **Never commit**:
   - Database files (db.sqlite3)
   - Environment variables (.env)
   - API keys or secrets
   - Large binary files (>100MB)
   - Personal data or PII

2. **Always commit**:
   - Source code
   - Documentation
   - Configuration files (without secrets)
   - Requirements/dependencies files
   - README and LICENSE

3. **Model files**: Your .pkl files (~10MB) are fine to commit. For larger models (>100MB), use Git LFS.

---

## 📞 Need Help?

If you encounter issues:
- **Large files**: Use Git LFS or exclude them
- **Sensitive data**: Use `git filter-branch` to remove from history
- **Push rejected**: Check file sizes and .gitignore

---

**Last Updated**: February 14, 2026
**Repository**: https://github.com/YOUR_USERNAME/CMAM_ML_System
