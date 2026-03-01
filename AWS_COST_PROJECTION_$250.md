# AWS Cost Projection with $250 Credits
## Gelmëth CMAM System - Budget Planning

---

## 💰 Your AWS Credits

**Total Credits Available**: $250.00
- AWS Cloud Clubs: $25.00 (expires 12/31/2026)
- AWS Cloud Clubs: $25.00 (expires 12/31/2026)
- DR - Usage Review: $200.00 (expires 07/29/2026)

**Credits Used**: $0.00  
**Credits Remaining**: $250.00

---

## 📊 Monthly Cost Breakdown

### Option 1: Basic Setup (Recommended for Start)

| Service | Free Tier (12 months) | After Free Tier |
|---------|----------------------|-----------------|
| **EC2 t3.micro** | $0 | $7.50/month |
| **EBS 30GB** | $3/month | $3/month |
| **RDS db.t3.micro** | $0 | $15/month |
| **S3 Storage** | $0.50/month | $0.50/month |
| **Data Transfer** | $1/month | $5/month |
| **Total** | **$4.50/month** | **$30.50/month** |

### Option 2: Production Setup (Better Performance)

| Service | Cost |
|---------|------|
| **EC2 t3.small** | $15/month |
| **EBS 50GB** | $5/month |
| **RDS db.t3.small** | $30/month |
| **S3 + CloudFront** | $2/month |
| **Data Transfer** | $8/month |
| **Total** | **$60/month** |

---

## 🎯 How Long Will $250 Last?

### Scenario 1: Using Free Tier (First 12 Months)
- **Monthly Cost**: $4.50
- **Duration**: 12 months (Free Tier period)
- **Total Spent**: $54
- **Credits Remaining**: $196

### Scenario 2: After Free Tier (Basic Setup)
- **Monthly Cost**: $30.50
- **Credits Remaining**: $196
- **Duration**: 6.4 months
- **Total Runtime**: **18.4 months** (1.5 years!)

### Scenario 3: Production Setup (No Free Tier)
- **Monthly Cost**: $60
- **Duration**: 4.2 months
- **Total Runtime**: **4.2 months**

---

## 🚀 Recommended Deployment Strategy

### Phase 1: Development & Testing (Months 1-2)
**Use**: Basic Setup with Free Tier  
**Cost**: $4.50/month × 2 = $9  
**Purpose**: Test system, train CHWs, fix bugs

### Phase 2: Pilot Program (Months 3-6)
**Use**: Basic Setup with Free Tier  
**Cost**: $4.50/month × 4 = $18  
**Purpose**: Deploy to 2-3 facilities, gather feedback

### Phase 3: Scale Up (Months 7-12)
**Use**: Basic Setup with Free Tier  
**Cost**: $4.50/month × 6 = $27  
**Purpose**: Expand to 10+ facilities

### Phase 4: Full Production (After Month 12)
**Use**: Production Setup (no Free Tier)  
**Cost**: $60/month  
**Credits Remaining**: $196  
**Duration**: 3.3 months

**Total Runtime with $250**: **15.3 months** (1 year 3 months)

---

## 💡 Cost Optimization Tips

### 1. Use Reserved Instances (Save 30-50%)
After 3 months of stable usage:
```bash
# Purchase 1-year Reserved Instance
# EC2 t3.micro: $7.50/month → $4.50/month (40% savings)
# RDS db.t3.micro: $15/month → $9/month (40% savings)
```

**New Monthly Cost**: $18/month (instead of $30.50)  
**Extended Runtime**: 10.9 months (instead of 6.4 months)

### 2. Use Spot Instances for Development
For testing environments:
```bash
# EC2 Spot: $7.50/month → $2.25/month (70% savings)
```

### 3. Enable S3 Lifecycle Policies
```bash
# Move old backups to Glacier after 30 days
# Cost: $0.50/month → $0.10/month
```

### 4. Use CloudFront Caching
```bash
# Reduce data transfer costs by 60%
# Cost: $5/month → $2/month
```

### 5. Schedule EC2 Instances
For development/testing:
```bash
# Stop instances during off-hours (8 PM - 8 AM)
# Save 50% on EC2 costs
```

---

## 📈 Extended Budget Projection

### With Cost Optimization:

| Phase | Duration | Monthly Cost | Total Cost |
|-------|----------|--------------|------------|
| **Free Tier** | 12 months | $4.50 | $54 |
| **Reserved Instances** | 12 months | $18 | $216 |
| **Total** | **24 months** | - | **$270** |

**With $250 credits**: You can run for **22 months** (almost 2 years!)

---

## 🎯 Budget Alerts Setup

### Set Up 3 Budget Alerts:

1. **Alert 1**: When $50 spent (20% of credits)
   - Action: Review usage, optimize if needed

2. **Alert 2**: When $125 spent (50% of credits)
   - Action: Consider Reserved Instances

3. **Alert 3**: When $200 spent (80% of credits)
   - Action: Plan for additional funding or scale down

### How to Set Up:

```bash
# Go to AWS Budgets
https://console.aws.amazon.com/billing/home#/budgets

# Create Budget
1. Click "Create budget"
2. Choose "Cost budget"
3. Set amount: $250
4. Set alerts at: $50, $125, $200
5. Enter your email
6. Create budget
```

---

## 📊 Real-Time Cost Tracking

### Daily Monitoring:

```bash
# Check current month spending
aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity DAILY \
  --metrics BlendedCost
```

### Weekly Reports:

1. Go to AWS Cost Explorer
2. View by service
3. Identify top 3 cost drivers
4. Optimize accordingly

---

## 🚨 Cost Overrun Prevention

### Automatic Shutdown Rules:

**For Development Instances:**
```bash
# Create Lambda function to stop instances at 8 PM
# Save ~50% on EC2 costs during testing phase
```

**For RDS:**
```bash
# Use Aurora Serverless (pay per second)
# Cost: $0 when not in use
```

**For S3:**
```bash
# Enable versioning with lifecycle rules
# Delete old versions after 30 days
```

---

## 💰 Funding Strategy After Credits

### Option 1: Ministry of Health Budget
- Request $30-60/month operational budget
- Present cost-benefit analysis
- Show impact metrics (children screened, lives saved)

### Option 2: NGO Partnership
- Partner with UNICEF, WHO, or MSF
- Request infrastructure support
- Typical commitment: $500-1000/year

### Option 3: Grant Funding
- Apply for digital health grants
- Highlight AWS credits utilization
- Request $1000-2000 for 2-year operation

### Option 4: Hybrid Approach
- Keep backend on AWS ($30/month)
- Move dashboard to free hosting (Netlify/Vercel)
- Reduce to $20/month

---

## 📅 Timeline with $250 Credits

```
Month 1-2:   Development & Testing        ($9 total)
Month 3-6:   Pilot Program (3 facilities) ($18 total)
Month 7-12:  Expansion (10 facilities)    ($27 total)
Month 13:    Free Tier ends               
Month 13-15: Production (full cost)       ($90 total)
Month 16-18: Reserved Instances           ($54 total)
Month 19-22: Optimized setup              ($72 total)

Total: $270 over 22 months
Credits: $250
Out-of-pocket: $20 (for last month)
```

---

## 🎉 Summary

### With Your $250 Credits:

✅ **Runtime**: 18-22 months (1.5-2 years)  
✅ **Free Tier**: First 12 months at $4.50/month  
✅ **After Free Tier**: 6-10 months at $18-30/month  
✅ **Total Cost**: $250 (fully covered by credits!)  
✅ **Out-of-pocket**: $0-20 (minimal)  

### Recommended Action Plan:

1. **Start with Basic Setup** (Free Tier)
2. **Monitor costs weekly** (set up alerts)
3. **Optimize after 3 months** (Reserved Instances)
4. **Plan funding at Month 18** (before credits run out)
5. **Scale based on usage** (add resources as needed)

---

## 🚀 You're Ready to Deploy!

With $250 in credits, you have:
- **Plenty of runway** for development and testing
- **Time to prove value** before needing additional funding
- **Flexibility to scale** as the program grows
- **Buffer for mistakes** and learning

**Next Step**: Follow the deployment guide and start building! 🎉

---

**Questions?**
- AWS Cost Calculator: https://calculator.aws
- AWS Free Tier: https://aws.amazon.com/free
- AWS Support: https://console.aws.amazon.com/support
