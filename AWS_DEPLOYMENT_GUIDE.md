# AWS Deployment Guide - CMAM ML System

## Budget: $100 AWS Credit

### Architecture Overview

```
Mobile App (APK) → API Gateway → EC2/Lambda → RDS PostgreSQL
                                    ↓
                              S3 (ML Models)
                                    ↓
Web Dashboard (S3 + CloudFront)
```

---

## Deployment Plan

### Phase 1: Backend API (Django) - $30/month

**Option A: EC2 (Recommended for ML models)**
- **Instance**: t3.micro (Free Tier eligible for 12 months)
- **Cost**: $0 (Free Tier) or $7.50/month after
- **Specs**: 2 vCPU, 1GB RAM
- **Storage**: 30GB EBS ($3/month)

**Setup Steps:**
```bash
# 1. Launch EC2 instance
Instance Type: t3.micro
AMI: Ubuntu 22.04 LTS
Security Group: Allow ports 22, 80, 443, 8000

# 2. SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 3. Install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install python3.11 python3-pip nginx postgresql-client git -y

# 4. Clone repository
git clone https://github.com/YOUR_USERNAME/CMAM_ML_System.git
cd CMAM_ML_System/gelmath_backend

# 5. Setup virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt gunicorn

# 6. Configure environment
nano .env
```

**.env Configuration:**
```env
SECRET_KEY=your-production-secret-key-here
DEBUG=False
ALLOWED_HOSTS=your-domain.com,your-ec2-ip
DATABASE_URL=postgresql://user:password@rds-endpoint:5432/cmam_db
AWS_STORAGE_BUCKET_NAME=cmam-ml-models
AWS_S3_REGION_NAME=us-east-1
```

**Gunicorn Service:**
```bash
# Create systemd service
sudo nano /etc/systemd/system/gunicorn.service
```

```ini
[Unit]
Description=Gunicorn for CMAM Backend
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/CMAM_ML_System/gelmath_backend
Environment="PATH=/home/ubuntu/CMAM_ML_System/gelmath_backend/venv/bin"
ExecStart=/home/ubuntu/CMAM_ML_System/gelmath_backend/venv/bin/gunicorn \
          --workers 2 \
          --bind 0.0.0.0:8000 \
          gelmath_project.wsgi:application

[Install]
WantedBy=multi-user.target
```

```bash
# Start service
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
```

**Nginx Configuration:**
```bash
sudo nano /etc/nginx/sites-available/cmam
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /home/ubuntu/CMAM_ML_System/gelmath_backend/staticfiles/;
    }

    location /media/ {
        alias /home/ubuntu/CMAM_ML_System/gelmath_backend/media/;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/cmam /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

### Phase 2: Database - $15/month

**RDS PostgreSQL (Free Tier)**
- **Instance**: db.t3.micro (Free Tier eligible)
- **Cost**: $0 (Free Tier) or $15/month after
- **Storage**: 20GB SSD (Free Tier)

**Setup:**
1. Go to AWS RDS Console
2. Create Database:
   - Engine: PostgreSQL 15
   - Template: Free tier
   - DB instance: db.t3.micro
   - Storage: 20GB
   - Username: cmam_admin
   - Password: [secure password]
   - Public access: No
   - VPC: Same as EC2

3. Security Group:
   - Allow PostgreSQL (5432) from EC2 security group

4. Initialize database:
```bash
# From EC2 instance
psql -h your-rds-endpoint -U cmam_admin -d postgres
CREATE DATABASE cmam_db;
\q

# Run migrations
cd /home/ubuntu/CMAM_ML_System/gelmath_backend
source venv/bin/activate
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
```

---

### Phase 3: ML Models Storage - $1/month

**S3 Bucket**
- **Cost**: ~$0.50/month (for 2 model files ~10MB)

**Setup:**
```bash
# Create S3 bucket
aws s3 mb s3://cmam-ml-models --region us-east-1

# Upload models
aws s3 cp Models/cmam_model.pkl s3://cmam-ml-models/
aws s3 cp Models/model2_quality_classifier.pkl s3://cmam-ml-models/

# Set bucket policy (private)
```

**Update Django settings:**
```python
# settings.py
AWS_ACCESS_KEY_ID = 'your-access-key'
AWS_SECRET_ACCESS_KEY = 'your-secret-key'
AWS_STORAGE_BUCKET_NAME = 'cmam-ml-models'
AWS_S3_REGION_NAME = 'us-east-1'
```

---

### Phase 4: Web Dashboard - $5/month

**S3 + CloudFront**
- **S3**: $0.50/month (hosting)
- **CloudFront**: $1/month (CDN)
- **Route 53**: $0.50/month (DNS)

**Setup:**
```bash
# Build React app
cd gelmath_web
npm run build

# Create S3 bucket for website
aws s3 mb s3://cmam-dashboard --region us-east-1

# Enable static website hosting
aws s3 website s3://cmam-dashboard --index-document index.html --error-document index.html

# Upload build files
aws s3 sync build/ s3://cmam-dashboard --acl public-read

# Create CloudFront distribution
# Go to CloudFront console
# Origin: cmam-dashboard.s3-website-us-east-1.amazonaws.com
# Default root object: index.html
```

**Update API URL in React:**
```javascript
// .env.production
REACT_APP_API_URL=https://api.your-domain.com
```

---

### Phase 5: SSL Certificate - FREE

**AWS Certificate Manager (ACM)**
```bash
# Request certificate
1. Go to ACM Console
2. Request public certificate
3. Domain: *.your-domain.com, your-domain.com
4. Validation: DNS
5. Add CNAME records to Route 53
6. Wait for validation (5-30 minutes)

# Attach to Load Balancer or CloudFront
```

---

### Phase 6: Mobile App (APK)

**Build APK:**
```bash
cd cmam_mobile_app

# Update API endpoint
# lib/services/api_service.dart
static const String baseUrl = 'https://api.your-domain.com/api';

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Distribution Options:**
1. **Direct Download**: Upload APK to S3 bucket
2. **Google Play Store**: $25 one-time fee (outside AWS budget)
3. **Internal Distribution**: Email/WhatsApp to CHWs

---

## Cost Breakdown (Monthly)

| Service | Free Tier | After Free Tier |
|---------|-----------|-----------------|
| EC2 t3.micro | $0 | $7.50 |
| EBS 30GB | $3 | $3 |
| RDS db.t3.micro | $0 | $15 |
| S3 Storage | $0.50 | $0.50 |
| CloudFront | $1 | $1 |
| Route 53 | $0.50 | $0.50 |
| Data Transfer | $1 | $5 |
| **Total** | **$5/month** | **$32.50/month** |

**With $100 credit:**
- Free Tier (12 months): ~$5/month = $60 total
- After Free Tier: $32.50/month = 3 months
- **Total runtime: ~15 months**

---

## Alternative: Serverless (Lower Cost)

### Lambda + API Gateway - $2/month

**Benefits:**
- Pay per request
- Auto-scaling
- No server management

**Limitations:**
- ML model loading slower (cold start)
- 15-minute timeout
- Complex setup

**Cost:**
- 1M requests/month: $0.20
- API Gateway: $1/month
- **Total: $2/month**

---

## Deployment Checklist

### Pre-Deployment
- [ ] Register domain name (Namecheap: $10/year)
- [ ] Create AWS account
- [ ] Verify $100 credit applied
- [ ] Setup AWS CLI locally

### Backend Deployment
- [ ] Launch EC2 instance
- [ ] Setup RDS PostgreSQL
- [ ] Configure security groups
- [ ] Install dependencies
- [ ] Deploy Django app
- [ ] Setup Gunicorn + Nginx
- [ ] Run migrations
- [ ] Create superuser
- [ ] Upload ML models to S3

### Frontend Deployment
- [ ] Build React app
- [ ] Create S3 bucket
- [ ] Upload build files
- [ ] Setup CloudFront
- [ ] Configure custom domain

### SSL & DNS
- [ ] Request SSL certificate (ACM)
- [ ] Setup Route 53 hosted zone
- [ ] Configure DNS records
- [ ] Enable HTTPS

### Mobile App
- [ ] Update API endpoint
- [ ] Build release APK
- [ ] Test on physical device
- [ ] Distribute to CHWs

### Testing
- [ ] Test API endpoints
- [ ] Test web dashboard
- [ ] Test mobile app sync
- [ ] Load testing
- [ ] Security audit

### Monitoring
- [ ] Setup CloudWatch alarms
- [ ] Configure error logging
- [ ] Monitor costs
- [ ] Setup backups

---

## Quick Start Commands

```bash
# 1. Setup AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output (json)

# 2. Create key pair
aws ec2 create-key-pair --key-name cmam-key --query 'KeyMaterial' --output text > cmam-key.pem
chmod 400 cmam-key.pem

# 3. Launch EC2
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name cmam-key \
  --security-group-ids sg-xxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CMAM-Backend}]'

# 4. Get instance IP
aws ec2 describe-instances --filters "Name=tag:Name,Values=CMAM-Backend" --query 'Reservations[0].Instances[0].PublicIpAddress'

# 5. SSH into instance
ssh -i cmam-key.pem ubuntu@<instance-ip>
```

---

## Estimated Timeline

- **Day 1**: AWS account setup, EC2 + RDS deployment
- **Day 2**: Backend deployment, database migration
- **Day 3**: Web dashboard deployment, SSL setup
- **Day 4**: Mobile app build, testing
- **Day 5**: Final testing, documentation

---

## Support & Maintenance

**Monthly Tasks:**
- Monitor AWS costs
- Check CloudWatch logs
- Update dependencies
- Backup database
- Review security

**Cost Optimization:**
- Use Reserved Instances (save 30-50%)
- Enable S3 lifecycle policies
- Use CloudFront caching
- Compress static assets
- Monitor unused resources

---

## Next Steps

1. Create AWS account and verify $100 credit
2. Register domain name
3. Follow deployment checklist
4. Test thoroughly before production
5. Train CHWs on mobile app usage

---

**Estimated Total Cost: $5-10/month (with Free Tier)**
**Deployment Time: 3-5 days**
**Production Ready: Yes**
