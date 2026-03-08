# 📱 Mobile App Build & Distribution Guide

## Quick Build Commands

### Android APK (Recommended for Testing)
```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app
flutter build apk --release
```
**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (For Google Play Store)
```bash
flutter build appbundle --release
```
**Output**: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Requires Mac + Xcode)
```bash
flutter build ios --release
```

---

## Step-by-Step: Build Android APK

### 1. Pre-Build Checklist

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Verify no errors
flutter analyze
```

### 2. Update App Configuration

**File**: `android/app/build.gradle`

Check these settings:
```gradle
android {
    defaultConfig {
        applicationId "com.gelmath.cmam"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 3. Build Release APK

```bash
flutter build apk --release --split-per-abi
```

This creates 3 optimized APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM) ← Most common
- `app-x86_64-release.apk` (Intel/AMD)

**Or build universal APK** (larger file, works on all devices):
```bash
flutter build apk --release
```

### 4. Locate Your APK

```bash
# Universal APK
open build/app/outputs/flutter-apk/

# Or use Finder
# Navigate to: cmam_mobile_app/build/app/outputs/flutter-apk/
```

**File**: `app-release.apk` (~20-40 MB)

---

## Distribution Methods

### Method 1: Direct APK Distribution (Easiest)

**Best for**: Pilot testing, CHWs in field, internal distribution

#### Share via:
1. **USB/SD Card**: Copy APK to device storage
2. **WhatsApp/Email**: Send APK file directly
3. **Cloud Storage**: Upload to Google Drive/Dropbox
4. **Web Server**: Host on your EC2 instance

#### Installation Instructions for Users:

**Step 1**: Enable "Install from Unknown Sources"
- Go to **Settings** → **Security**
- Enable **"Unknown sources"** or **"Install unknown apps"**

**Step 2**: Download APK
- Transfer APK to phone
- Tap on `app-release.apk` file

**Step 3**: Install
- Tap **"Install"**
- Tap **"Open"** when done

---

### Method 2: Host APK on Your Server

Upload to EC2 for easy distribution:

```bash
# On your Mac, upload APK to EC2
scp -i ~/gelmath-key.pem \
  build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@100.54.11.150:/home/ubuntu/

# SSH to EC2
ssh -i ~/gelmath-key.pem ubuntu@100.54.11.150

# Move to web-accessible location
sudo mkdir -p /var/www/html/downloads
sudo mv app-release.apk /var/www/html/downloads/gelmath-cmam-v1.0.0.apk
sudo chmod 644 /var/www/html/downloads/gelmath-cmam-v1.0.0.apk
```

**Configure Nginx** to serve downloads:
```bash
sudo nano /etc/nginx/sites-available/gelmath
```

Add this location block:
```nginx
location /downloads/ {
    alias /var/www/html/downloads/;
    autoindex on;
}
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

**Share download link**:
```
http://100.54.11.150/downloads/gelmath-cmam-v1.0.0.apk
```

Users can download directly from browser!

---

### Method 3: Google Play Store (Official)

**Best for**: Wide distribution, automatic updates, credibility

#### Requirements:
- Google Play Developer account ($25 one-time fee)
- App Bundle (not APK)
- Privacy policy URL
- App screenshots
- Store listing content

#### Build App Bundle:
```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

#### Upload to Play Store:
1. Go to https://play.google.com/console
2. Create new app
3. Upload `app-release.aab`
4. Fill store listing
5. Submit for review (2-7 days)

---

## iOS Build (Mac Only)

### Prerequisites:
- Mac computer
- Xcode 14+ installed
- Apple Developer account ($99/year)

### Build Steps:

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app

# Clean
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

### In Xcode:
1. Select **Runner** project
2. Go to **Signing & Capabilities**
3. Select your **Team**
4. Choose **Product** → **Archive**
5. Click **Distribute App**
6. Choose distribution method:
   - **App Store Connect** (official)
   - **Ad Hoc** (testing, up to 100 devices)
   - **Enterprise** (internal distribution)

---

## App Signing (Optional but Recommended)

### Why Sign Your App?
- Prevents tampering
- Enables updates
- Required for Play Store

### Generate Signing Key:

```bash
# On Mac/Linux
keytool -genkey -v -keystore ~/gelmath-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias gelmath

# Enter password (remember this!)
# Fill in organization details
```

### Configure Signing:

**Create**: `android/key.properties`
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=gelmath
storeFile=/Users/ram/gelmath-release-key.jks
```

**Edit**: `android/app/build.gradle`
```gradle
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**Rebuild**:
```bash
flutter build apk --release
```

---

## Testing Your APK

### Test on Physical Device:

```bash
# Connect Android device via USB
# Enable USB debugging on device

# Install APK
flutter install

# Or use adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Test Checklist:
- [ ] App launches successfully
- [ ] Login works with backend
- [ ] Assessment form accepts input
- [ ] ML prediction returns results
- [ ] Offline mode works (airplane mode)
- [ ] Data syncs when online
- [ ] History shows past assessments
- [ ] No crashes or errors

---

## Version Management

### Update Version for New Releases:

**File**: `pubspec.yaml`
```yaml
version: 1.0.1+2
#        │   │ │
#        │   │ └─ Build number (increment each build)
#        │   └─── Patch version
#        └─────── Major.Minor version
```

**Rebuild after version change**:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## Distribution Checklist

### Before Distribution:
- [ ] Test on multiple devices
- [ ] Verify backend connectivity
- [ ] Check offline functionality
- [ ] Test all user roles (CHW, Doctor, Admin)
- [ ] Verify data sync works
- [ ] Test on different Android versions
- [ ] Check app permissions
- [ ] Verify app icon displays correctly

### Prepare Documentation:
- [ ] Installation guide for users
- [ ] User manual (how to use app)
- [ ] Troubleshooting guide
- [ ] Contact information for support

---

## Quick Distribution Package

Create a distribution folder:

```bash
cd /Users/ram/Downloads/MUAC_DEVELOPMENT

# Create distribution package
mkdir -p distribution/gelmath-cmam-v1.0.0
cp cmam_mobile_app/build/app/outputs/flutter-apk/app-release.apk \
   distribution/gelmath-cmam-v1.0.0/

# Create installation guide
cat > distribution/gelmath-cmam-v1.0.0/INSTALL.txt << 'EOF'
GELMATH CMAM Mobile App - Installation Guide

1. ENABLE INSTALLATION FROM UNKNOWN SOURCES
   - Open Settings on your Android phone
   - Go to Security or Privacy
   - Enable "Install unknown apps" or "Unknown sources"

2. INSTALL THE APP
   - Locate the app-release.apk file
   - Tap on it
   - Tap "Install"
   - Wait for installation to complete
   - Tap "Open"

3. LOGIN
   - Use your assigned credentials
   - CHW users: chw_user / chw123
   - Doctor users: doctor_user / doctor123

4. SUPPORT
   - Email: support@gelmath.org
   - Phone: +211-XXX-XXXX

App Version: 1.0.0
Release Date: February 2026
EOF

# Create ZIP for distribution
cd distribution
zip -r gelmath-cmam-v1.0.0.zip gelmath-cmam-v1.0.0/
```

**Share**: `distribution/gelmath-cmam-v1.0.0.zip`

---

## File Sizes Reference

| Build Type | Size | Use Case |
|------------|------|----------|
| Debug APK | 60-80 MB | Development only |
| Release APK (universal) | 25-40 MB | General distribution |
| Release APK (split) | 15-25 MB | Optimized per device |
| App Bundle (.aab) | 20-30 MB | Play Store only |

---

## Common Issues & Solutions

### "App not installed"
- **Cause**: Conflicting signature
- **Fix**: Uninstall old version first

### "Parse error"
- **Cause**: Corrupted APK or incompatible Android version
- **Fix**: Re-download APK, check Android version (min 5.0)

### "Installation blocked"
- **Cause**: Unknown sources disabled
- **Fix**: Enable in Settings → Security

### App crashes on launch
- **Cause**: Missing permissions or backend unreachable
- **Fix**: Check internet connection, verify backend URL

---

## Next Steps

### Immediate:
1. **Build APK**: `flutter build apk --release`
2. **Test on device**: Install and verify functionality
3. **Share with pilot users**: Use direct APK distribution

### Short-term:
1. **Collect feedback**: From CHWs and doctors
2. **Fix bugs**: Update and release v1.0.1
3. **Host on server**: For easy distribution

### Long-term:
1. **Play Store**: Official distribution channel
2. **Auto-updates**: Implement in-app update mechanism
3. **Analytics**: Track usage and errors

---

## Build Commands Summary

```bash
# Navigate to project
cd /Users/ram/Downloads/MUAC_DEVELOPMENT/cmam_mobile_app

# Clean build
flutter clean && flutter pub get

# Build APK (universal)
flutter build apk --release

# Build APK (optimized)
flutter build apk --release --split-per-abi

# Build App Bundle (Play Store)
flutter build appbundle --release

# Install on connected device
flutter install

# Check APK size
ls -lh build/app/outputs/flutter-apk/
```

---

## Support & Resources

**Flutter Documentation**: https://docs.flutter.dev/deployment/android  
**Play Store Console**: https://play.google.com/console  
**App Signing**: https://developer.android.com/studio/publish/app-signing  

---

**Ready to Build!** 🚀📱

Run: `flutter build apk --release` to get started!
