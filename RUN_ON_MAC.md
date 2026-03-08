# 🔒 HTTPS Setup - Run on YOUR MAC

## ⚠️ IMPORTANT: Run these on YOUR MAC, not on EC2!

You were on EC2 server. Exit and run these locally.

---

## Step 1: Exit EC2 (if you're still connected)

```bash
exit
```

---

## Step 2: Update Frontend on YOUR MAC

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/gelmath_web

echo "REACT_APP_API_URL=https://100.54.11.150/api" > .env.production

npm run build

aws s3 sync build/ s3://gelmath-dashboard-2026/ --delete
```

---

## Step 3: Setup Backend HTTPS on EC2

Now SSH to EC2 and run backend setup:

```bash
ssh -i YOUR_KEY.pem ubuntu@100.54.11.150
```

Then paste this:

```bash
sudo mkdir -p /etc/nginx/ssl && \
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/gelmath.key \
  -out /etc/nginx/ssl/gelmath.crt \
  -subj "/C=SS/ST=CentralEquatoria/L=Juba/O=MoH/CN=100.54.11.150" && \
sudo tee /etc/nginx/sites-available/gelmath > /dev/null << 'EOF'
server {
    listen 443 ssl;
    server_name 100.54.11.150;
    ssl_certificate /etc/nginx/ssl/gelmath.crt;
    ssl_certificate_key /etc/nginx/ssl/gelmath.key;
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
        if ($request_method = 'OPTIONS') { return 204; }
    }
    location /static/ { alias /home/ubuntu/Gelmath-CMAM-System/gelmath_backend/staticfiles/; }
}
server {
    listen 80;
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        add_header 'Access-Control-Allow-Origin' '*' always;
        if ($request_method = 'OPTIONS') { return 204; }
    }
    location /static/ { alias /home/ubuntu/Gelmath-CMAM-System/gelmath_backend/staticfiles/; }
}
EOF
sudo nginx -t && sudo systemctl restart nginx && \
echo "✅ HTTPS enabled!" && \
exit
```

---

## Step 4: Test

Open: `http://gelmath-dashboard-2026.s3-website-us-east-1.amazonaws.com`

Login: `moh_admin` / `admin123`

Browser warning? Click "Advanced" → "Proceed"

---

## Summary

**WHERE TO RUN:**
- ✅ Step 2: YOUR MAC (has npm, aws cli)
- ✅ Step 3: EC2 SERVER (has nginx)

**DON'T:**
- ❌ Run npm on EC2 (not installed there)
- ❌ Run nginx commands on Mac (not needed)

---

**Start with Step 2 on your Mac!**
