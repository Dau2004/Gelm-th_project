# ✅ Facility Performance Tracking Enabled

## Why Facility Field is Critical

The `facility` field enables:

1. **Facility Performance Metrics**
   - Track assessments per facility
   - Monitor SAM/MAM rates by facility
   - Identify high-performing facilities
   - Detect facilities needing support

2. **Geographic Analysis**
   - Map malnutrition hotspots
   - Resource allocation decisions
   - Facility capacity planning

3. **CHW Performance by Facility**
   - Compare CHW effectiveness across facilities
   - Identify training needs
   - Optimize CHW deployment

## Implementation

### Mobile App Flow

1. **CHW Selects Facility**
   ```dart
   // Assessment Screen
   - State dropdown (Central Equatoria, etc.)
   - Facility dropdown (filtered by state)
   - Facility name stored in assessment
   ```

2. **API Converts Name → ID**
   ```dart
   // api_service.dart
   - Looks up facility by name
   - Converts to facility ID
   - Sends ID to backend
   ```

3. **Backend Stores Facility**
   ```python
   # Assessment model
   facility = ForeignKey(Facility)  # Links to facility table
   ```

### MoH Dashboard Views

#### Facilities Tab
Shows all facilities with performance metrics:
- Facility name
- State/County
- Total assessments
- SAM/MAM breakdown
- Active status

#### Analytics by Facility
```javascript
// Can filter by facility
GET /api/analytics/facility/{id}/
{
  "facility": "Central Equatoria Health Center",
  "total_assessments": 17,
  "sam_count": 7,
  "mam_count": 4,
  "healthy_count": 6
}
```

## Database Structure

### Facilities Table
```
ID | Name                              | State              | Type
---+-----------------------------------+--------------------+------
1  | Central Equatoria Health Center   | Central Equatoria  | OTP
2  | Eastern Equatoria Health Center   | Eastern Equatoria  | OTP
3  | Western Equatoria Health Center   | Western Equatoria  | TSFP
4  | Jonglei Health Center             | Jonglei            | OTP
5  | Unity Health Center               | Unity              | SC_ITP
```

### Assessments Table (with facility link)
```
ID | child_id | facility_id | state             | sam/mam
---+----------+-------------+-------------------+--------
1  | CH001    | 1           | Central Equatoria | SAM
2  | CH002    | 1           | Central Equatoria | MAM
3  | CH003    | 2           | Eastern Equatoria | SAM
```

## Benefits for MoH Dashboard

### 1. Facility Comparison
```
Facility A: 50 assessments, 10% SAM rate
Facility B: 30 assessments, 25% SAM rate ⚠️ Needs attention
```

### 2. Resource Allocation
```
High-burden facilities → More CHWs
Low-capacity facilities → Training support
```

### 3. Geographic Heatmap
```
Map shows:
- Facility locations
- Color-coded by SAM prevalence
- Size by assessment volume
```

### 4. Performance Reports
```
Top Performing Facilities:
1. Central Equatoria HC - 95% coverage
2. Unity HC - 90% coverage
3. Jonglei HC - 85% coverage
```

## Data Flow with Facility

```
Mobile App
  ↓ (CHW selects: "Central Equatoria Health Center")
API Service
  ↓ (Converts to facility_id: 1)
Backend
  ↓ (Stores: facility_id=1)
PostgreSQL
  ↓ (Links to Facility table)
MoH Dashboard
  ↓ (Displays: "Central Equatoria HC: 17 assessments")
```

## Verification

Check facility data is flowing:

```bash
# 1. Check facilities in database
cd gelmath_backend
python3 manage.py shell -c "
from accounts.models import Facility
from assessments.models import Assessment
for f in Facility.objects.all():
    count = Assessment.objects.filter(facility=f).count()
    print(f'{f.name}: {count} assessments')
"

# 2. Create assessment on mobile with facility selected

# 3. Verify in MoH Dashboard Facilities tab
```

## Result

✅ **Facility tracking fully enabled**
- Mobile app captures facility
- Backend stores facility link
- MoH Dashboard can analyze by facility
- Performance metrics available per facility
