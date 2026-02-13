# CMAM Mobile App

Modern Flutter mobile application for Community-based Management of Acute Malnutrition (CMAM) based on South Sudan Guidelines 2017.

## Features

✅ **Offline-First Architecture**
- Local SQLite database for data capture
- Auto-sync when internet available
- Works in remote areas without connectivity

✅ **Clinical Assessment**
- MUAC measurement (mm)
- Age-based Z-score calculation using WHO LMS method
- Real WHO reference tables (3-60 months)
- Edema detection
- Appetite test
- Danger signs checklist

✅ **ML-Powered Pathway Recommendation**
- Real-time classification: SAM/MAM/Healthy
- Care pathway prediction: SC-ITP / OTP / TSFP
- CMAM guideline gate for safety
- Confidence scoring

✅ **Modern UI/UX**
- Clean, intuitive interface
- Dark green (#2D5F3F) primary color
- White secondary color
- Responsive design

## Architecture

```
Input → Z-Score Calculation → Clinical Status → ML Prediction → Guideline Gate → Action
```

### Flow
1. CHW enters child data (sex, age, MUAC, edema, appetite, danger signs)
2. App calculates MUAC Z-score using LMS tables
3. Determines clinical status (SAM/MAM/Healthy)
4. ML model predicts care pathway
5. Guideline gate validates against CMAM rules
6. Displays recommendation with confidence
7. Stores offline, syncs to backend when online

## Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Physical device or emulator

### Installation

```bash
cd cmam_mobile_app

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── child_assessment.dart # Assessment data model
│   └── lms_reference.dart    # LMS reference data
├── services/
│   ├── database_service.dart # SQLite offline storage
│   ├── zscore_service.dart   # Z-score calculation
│   ├── prediction_service.dart # ML pathway prediction
│   └── api_service.dart      # Backend sync
├── screens/
│   ├── home_screen.dart      # Main menu
│   ├── assessment_screen.dart # Data capture form
│   ├── result_screen.dart    # Recommendation display
│   └── history_screen.dart   # Past assessments
└── widgets/                  # Reusable UI components
```

## Configuration

### Backend URL
Edit `lib/services/api_service.dart`:

```dart
// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For iOS simulator
static const String baseUrl = 'http://localhost:8000/api';

// For physical device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

## CMAM Classification Logic

### Clinical Status (from Z-score)
- **SAM**: Z-score < -3 OR edema present
- **MAM**: -3 ≤ Z-score < -2
- **Healthy**: Z-score ≥ -2

### Care Pathway (CMAM Guidelines)
- **SC-ITP**: SAM + (danger signs OR poor appetite OR edema)
- **OTP**: SAM + good appetite + no complications
- **TSFP**: MAM + good appetite + no complications
- **None**: Healthy (counselling only)

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Build & Deploy

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open in Xcode for signing and distribution
```

## Troubleshooting

### Database Issues
```bash
# Clear app data
flutter clean
flutter pub get
```

### Sync Issues
- Check backend is running
- Verify network connectivity
- Check API URL configuration

## Next Steps

- [ ] Add photo capture for edema verification
- [ ] Implement follow-up scheduling
- [ ] Add RUTF stock management
- [ ] Multi-language support (Arabic, local languages)
- [ ] Biometric authentication for CHWs
- [ ] Offline map integration for home visits

## License

MIT License - See LICENSE file

## Support

For issues and questions, contact the development team.
