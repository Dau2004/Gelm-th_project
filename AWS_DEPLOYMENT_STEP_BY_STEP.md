# Complete AWS Deployment Guide for Beginners
## Gelmëth CMAM System - Step-by-Step Deployment

---

## 📋 Prerequisites

### What You Need:
1. **AWS Account** (with $100 credit)
2. **Domain Name** (optional but recommended - $10/year from Namecheap)
3. **Computer** with internet connection
4. **GitHub Account** (to host your code)
5. **Basic terminal/command line knowledge**

### Estimated Costs:
- **With Free Tier**: $5-10/month
- **After Free Tier**: $32.50/month
- **With $100 credit**: ~15 months of operation

---

## Part 1: AWS Account Setup (30 minutes)

### Step 1.1: Create AWS Account

1. Go to https://aws.amazon.com/
2. Click **"Create an AWS Account"**
3. Enter your email and choose account name
4. Provide contact information
5. Enter credit card details (required, but won't be charged with Free Tier)
6. Verify phone number
7. Choose **"Basic Support - Free"** plan

### Step 1.2: Apply $100 Credit

1. Go to **AWS Credits** page: https://console.aws.amazon.com/billing/home#/credits
2. Enter your promotional code
3. Verify credit is applied (shows in Billing Dashboard)

### Step 1.3: Setup AWS CLI on Your Computer

**For macOS:**
```bash
# Install AWS CLI
brew install awscli

# Verify installation
aws --version
```

**For Windows:**
1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run installer
3. Open Command Prompt and verify: `aws --version`

**For Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### Step 1.4: Create Access Keys

1. Go to AWS Console: https://console.aws.amazon.com/
2. Click your name (top right) → **Security Credentials**
3. Scroll to **"Access keys"** section
4. Click **"Create access key"**
5. Choose **"Command Line Interface (CLI)"**
6. Check the box and click **"Next"**
7. Add description: "CMAM Deployment"
8. Click **"Create access key"**
9. **IMPORTANT**: Download the CSV file (you'll need this!)

### Step 1.5: Configure AWS CLI

```bash
aws configure
```

Enter the following when prompted:
```
AWS Access Key ID: [paste from CSV file]
AWS Secret Access Key: [paste from CSV file]
Default region name: us-east-1
Default output format: json
```

Test configuration:
```bash
aws sts get-caller-identity
```

You should see your account details!

---

## Part 2: Push Code to GitHub (15 minutes)

### Step 2.1: Create GitHub Repository

1. Go to https://github.com/
2. Click **"New repository"**
3. Name: `Gelmath-CMAM-System`
4. Description: "Gelmëth CMAM ML System for South Sudan"
5. Choose **"Private"** (recommended)
6. Click **"Create repository"**

### Step 2.2: Push Your Code

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT

# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Gelmëth CMAM System"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/Gelmath-CMAM-System.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Part 3: Deploy Backend on EC2 (1-2 hours)

### Step 3.1: Create SSH Key Pair

```bash
# Create key pair
aws ec2 create-key-pair \
  --key-name gelmath-key \
  --query 'KeyMaterial' \
  --output text > gelmath-key.pem

# Set permissions (macOS/Linux)
chmod 400 gelmath-key.pem

# For Windows, use:
# icacls gelmath-key.pem /inheritance:r
# icacls gelmath-key.pem /grant:r "%username%:R"
```

### Step 3.2: Create Security Group

```bash
# Create security group
aws ec2 create-security-group \
  --group-name gelmath-sg \
  --description "Security group for Gelmath CMAM system"

# Note the GroupId from output (e.g., sg-0123456789abcdef0)
```

Save the `GroupId` - you'll need it!

```bash
# Allow SSH (port 22)
aws ec2 authorize-security-group-ingress \
  --group-name gelmath-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress \
  --group-name gelmath-sg \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS (port 443)
aws ec2 authorize-security-group-ingress \
  --group-name gelmath-sg \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Allow Django dev server (port 8000)
aws ec2 authorize-security-group-ingress \
  --group-name gelmath-sg \
  --protocol tcp \
  --port 8000 \
  --cidr 0.0.0.0/0
```

### Step 3.3: Launch EC2 Instance

```bash
# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name gelmath-key \
  --security-groups gelmath-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Gelmath-Backend}]'
```

**Note the `InstanceId` from output!**

### Step 3.4: Get Instance Public IP

```bash
# Get public IP
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Gelmath-Backend" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

Save this IP address!

### Step 3.5: Connect to EC2 Instance

```bash
# SSH into instance (replace <PUBLIC-IP> with your IP)
ssh -i gelmath-key.pem ubuntu@<PUBLIC-IP>
```

If you see a warning, type `yes` and press Enter.

You're now inside your EC2 server! 🎉

### Step 3.6: Install Dependencies on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python 3.11
sudo apt install python3.11 python3.11-venv python3-pip -y

# Install other dependencies
sudo apt install nginx postgresql-client git -y

# Verify installations
python3.11 --version
nginx -v
git --version
```

### Step 3.7: Clone Your Repository

```bash
# Clone repository (replace YOUR_USERNAME)
git clone https://github.com/YOUR_USERNAME/Gelmath-CMAM-System.git
cd Gelmath-CMAM-System/gelmath_backend
```

If repository is private, you'll need to authenticate:
```bash
# Use personal access token
git clone https://<YOUR_TOKEN>@github.com/YOUR_USERNAME/Gelmath-CMAM-System.git
```

### Step 3.8: Setup Python Virtual Environment

```bash
# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# You should see (venv) in your prompt

# Install Python packages
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn
```

### Step 3.9: Configure Environment Variables

```bash
# Create .env file
nano .env
```

Paste this content (press `Ctrl+Shift+V` to paste):
```env
SECRET_KEY=your-super-secret-key-change-this-in-production-12345
DEBUG=False
ALLOWED_HOSTS=<YOUR-EC2-PUBLIC-IP>,localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
```

**Replace `<YOUR-EC2-PUBLIC-IP>` with your actual IP!**

Press `Ctrl+X`, then `Y`, then `Enter` to save.

### Step 3.10: Run Database Migrations

```bash
# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser
# Enter username: admin
# Enter email: admin@gelmath.org
# Enter password: (choose a strong password)

# Collect static files
python manage.py collectstatic --noinput
```

### Step 3.11: Test Django Server

```bash
# Run development server
python manage.py runserver 0.0.0.0:8000
```

Open browser and go to: `http://<YOUR-EC2-IP>:8000/api/`

You should see the Django REST API page! 🎉

Press `Ctrl+C` to stop the server.

### Step 3.12: Setup Gunicorn (Production Server)

```bash
# Test Gunicorn
gunicorn --bind 0.0.0.0:8000 gelmath_api.wsgi:application
```

Test in browser again. If it works, press `Ctrl+C`.

```bash
# Create Gunicorn service
sudo nano /etc/systemd/system/gunicorn.service
```

Paste this content:
```ini
[Unit]
Description=Gunicorn for Gelmath Backend
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/Gelmath-CMAM-System/gelmath_backend
Environment="PATH=/home/ubuntu/Gelmath-CMAM-System/gelmath_backend/venv/bin"
ExecStart=/home/ubuntu/Gelmath-CMAM-System/gelmath_backend/venv/bin/gunicorn \
          --workers 2 \
          --bind 0.0.0.0:8000 \
          gelmath_api.wsgi:application

[Install]
WantedBy=multi-user.target
```

Save and exit (`Ctrl+X`, `Y`, `Enter`).

```bash
# Start Gunicorn service
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Check status
sudo systemctl status gunicorn
```

You should see "active (running)" in green!

### Step 3.13: Setup Nginx (Web Server)

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/gelmath
```

Paste this content (replace `<YOUR-EC2-IP>`):
```nginx
server {
    listen 80;
    server_name <YOUR-EC2-IP>;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /home/ubuntu/Gelmath-CMAM-System/gelmath_backend/staticfiles/;
    }

    location /media/ {
        alias /home/ubuntu/Gelmath-CMAM-System/gelmath_backend/media/;
    }
}
```

Save and exit.

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/gelmath /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx
```

### Step 3.14: Test Backend API

Open browser: `http://<YOUR-EC2-IP>/api/`

You should see the API! 🎉🎉🎉

**Backend is now deployed!**

---

## Part 4: Deploy Web Dashboard on S3 (30 minutes)

### Step 4.1: Build React App

On your local computer:

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_web

# Update API URL
nano .env.production
```

Add this line (replace with your EC2 IP):
```
REACT_APP_API_URL=http://<YOUR-EC2-IP>/api
```

Save and exit.

```bash
# Install dependencies
npm install

# Build for production
npm run build
```

You should see a `build/` folder created!

### Step 4.2: Create S3 Bucket

```bash
# Create bucket (choose unique name)
aws s3 mb s3://gelmath-dashboard-2026 --region us-east-1

# Enable static website hosting
aws s3 website s3://gelmath-dashboard-2026 \
  --index-document index.html \
  --error-document index.html
```

### Step 4.3: Upload Build Files

```bash
# Upload files
aws s3 sync build/ s3://gelmath-dashboard-2026 --acl public-read
```

### Step 4.4: Configure Bucket Policy

```bash
# Create policy file
cat > bucket-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::gelmath-dashboard-2026/*"
    }
  ]
}
EOF

# Apply policy
aws s3api put-bucket-policy \
  --bucket gelmath-dashboard-2026 \
  --policy file://bucket-policy.json
```

### Step 4.5: Access Dashboard

Your dashboard URL:
```
http://gelmath-dashboard-2026.s3-website-us-east-1.amazonaws.com
```

Open in browser - you should see the login page! 🎉

---

## Part 5: Deploy Mobile App (30 minutes)

### Step 5.1: Update API Endpoint

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app

# Edit API service
nano lib/services/api_service.dart
```

Find this line:
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

Change to (replace with your EC2 IP):
```dart
static const String baseUrl = 'http://<YOUR-EC2-IP>/api';
```

Save and exit.

### Step 5.2: Build APK

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build release APK
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Step 5.3: Upload APK to S3

```bash
# Create bucket for APK
aws s3 mb s3://gelmath-mobile-app --region us-east-1

# Upload APK
aws s3 cp build/app/outputs/flutter-apk/app-release.apk \
  s3://gelmath-mobile-app/gelmath-v1.0.0.apk \
  --acl public-read
```

### Step 5.4: Get Download Link

```bash
# Get APK URL
echo "https://gelmath-mobile-app.s3.amazonaws.com/gelmath-v1.0.0.apk"
```

Share this link with CHWs to download the app!

---

## Part 6: Setup Database (Optional - RDS PostgreSQL)

### Step 6.1: Create RDS Instance

1. Go to AWS Console: https://console.aws.amazon.com/rds/
2. Click **"Create database"**
3. Choose **"Standard create"**
4. Engine: **PostgreSQL**
5. Version: **PostgreSQL 15**
6. Templates: **Free tier**
7. DB instance identifier: `gelmath-db`
8. Master username: `postgres`
9. Master password: (choose strong password)
10. DB instance class: **db.t3.micro**
11. Storage: **20 GB**
12. Public access: **No**
13. VPC security group: Create new → `gelmath-db-sg`
14. Click **"Create database"**

Wait 5-10 minutes for creation.

### Step 6.2: Configure Security Group

1. Go to EC2 Console → Security Groups
2. Find `gelmath-db-sg`
3. Edit inbound rules
4. Add rule:
   - Type: PostgreSQL
   - Port: 5432
   - Source: `gelmath-sg` (your EC2 security group)
5. Save rules

### Step 6.3: Get RDS Endpoint

```bash
aws rds describe-db-instances \
  --db-instance-identifier gelmath-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

Save this endpoint!

### Step 6.4: Update Django Settings

SSH back into EC2:
```bash
ssh -i gelmath-key.pem ubuntu@<YOUR-EC2-IP>
cd Gelmath-CMAM-System/gelmath_backend
nano .env
```

Update DATABASE_URL:
```env
DATABASE_URL=postgresql://postgres:<PASSWORD>@<RDS-ENDPOINT>:5432/gelmath_db
```

Save and exit.

```bash
# Install PostgreSQL adapter
source venv/bin/activate
pip install psycopg2-binary

# Run migrations
python manage.py migrate

# Restart Gunicorn
sudo systemctl restart gunicorn
```

---

## Part 7: Testing & Verification

### Test Checklist:

1. **Backend API**
   - [ ] Visit `http://<EC2-IP>/api/`
   - [ ] Login to admin: `http://<EC2-IP>/admin/`
   - [ ] Test assessment endpoint

2. **Web Dashboard**
   - [ ] Visit S3 website URL
   - [ ] Login with credentials
   - [ ] View analytics
   - [ ] Check user management

3. **Mobile App**
   - [ ] Download APK
   - [ ] Install on Android device
   - [ ] Login
   - [ ] Create assessment
   - [ ] Check sync

---

## Part 8: Monitoring & Maintenance

### Setup CloudWatch Alarms

1. Go to CloudWatch Console
2. Create alarm for:
   - EC2 CPU > 80%
   - RDS connections > 80
   - Billing > $50

### Daily Checks:

```bash
# Check Gunicorn status
sudo systemctl status gunicorn

# Check Nginx status
sudo systemctl status nginx

# Check logs
sudo journalctl -u gunicorn -n 50

# Check disk space
df -h
```

### Weekly Backups:

```bash
# Backup database
python manage.py dumpdata > backup_$(date +%Y%m%d).json

# Upload to S3
aws s3 cp backup_*.json s3://gelmath-backups/
```

---

## Troubleshooting

### Issue: Can't connect to EC2

**Solution:**
```bash
# Check security group allows port 22
aws ec2 describe-security-groups --group-names gelmath-sg

# Check instance is running
aws ec2 describe-instances --filters "Name=tag:Name,Values=Gelmath-Backend"
```

### Issue: 502 Bad Gateway

**Solution:**
```bash
# Check Gunicorn is running
sudo systemctl status gunicorn

# Restart services
sudo systemctl restart gunicorn
sudo systemctl restart nginx
```

### Issue: Database connection error

**Solution:**
```bash
# Check RDS security group
# Ensure EC2 security group is allowed

# Test connection
psql -h <RDS-ENDPOINT> -U postgres -d gelmath_db
```

---

## Cost Monitoring

### Check Current Costs:

1. Go to AWS Billing Dashboard
2. View **"Bills"** section
3. Check **"Cost Explorer"**

### Set Budget Alert:

1. Go to AWS Budgets
2. Create budget: $50/month
3. Set alert at 80% ($40)

---

## Summary

✅ **Backend**: Deployed on EC2 with Gunicorn + Nginx  
✅ **Database**: SQLite (or PostgreSQL on RDS)  
✅ **Web Dashboard**: Hosted on S3  
✅ **Mobile App**: APK available for download  
✅ **Cost**: $5-10/month with Free Tier  

### Your URLs:

- **API**: `http://<YOUR-EC2-IP>/api/`
- **Admin**: `http://<YOUR-EC2-IP>/admin/`
- **Dashboard**: `http://gelmath-dashboard-2026.s3-website-us-east-1.amazonaws.com`
- **APK**: `https://gelmath-mobile-app.s3.amazonaws.com/gelmath-v1.0.0.apk`

---

## Next Steps

1. **Register Domain** (optional): Buy domain from Namecheap
2. **Setup SSL**: Use AWS Certificate Manager (free)
3. **Configure DNS**: Point domain to EC2/S3
4. **Train CHWs**: Distribute mobile app
5. **Monitor Usage**: Check CloudWatch daily

---

**Deployment Complete! 🎉🎉🎉**

**Questions?** Refer to AWS documentation or contact AWS Support.

**Estimated Total Time**: 4-6 hours  
**Difficulty**: Beginner-Friendly  
**Cost**: $5-10/month (Free Tier)
