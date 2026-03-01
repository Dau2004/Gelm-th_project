# Change Flutter App Icon to Gelmëth Logo

## App Name Changed ✅
The app name has been updated to "Gelmëth" in:
- Android: `AndroidManifest.xml`
- iOS: `Info.plist`

## Change App Icon

### Option 1: Using flutter_launcher_icons (Recommended)

1. **Add dependency to `pubspec.yaml`:**
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. **Add configuration to `pubspec.yaml`:**
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo_green.png"  # Use your Gelmëth logo
  adaptive_icon_background: "#0E4D34"
  adaptive_icon_foreground: "assets/images/logo_green.png"
```

3. **Run the command:**
```bash
cd cmam_mobile_app
flutter pub get
flutter pub run flutter_launcher_icons
```

### Option 2: Manual Icon Replacement

#### For Android:

Replace icons in these folders with your Gelmëth logo (different sizes):
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

#### For iOS:

Replace icons in:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

Required sizes:
- 20x20 (@1x, @2x, @3x)
- 29x29 (@1x, @2x, @3x)
- 40x40 (@1x, @2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (@1x)

### Prepare Your Logo

Use your existing logo at:
- `assets/images/logo_green.png` (for light backgrounds)
- `assets/images/logo_white.png` (for dark backgrounds)

**Recommended:** Use `logo_green.png` with transparent background for the app icon.

### Online Icon Generator Tools

If you need to generate all icon sizes:
1. **AppIcon.co** - https://www.appicon.co/
2. **Icon Kitchen** - https://icon.kitchen/
3. **MakeAppIcon** - https://makeappicon.com/

Upload your Gelmëth logo (1024x1024 PNG recommended) and download the generated icon sets.

### After Changing Icons

1. **Clean build:**
```bash
flutter clean
flutter pub get
```

2. **Rebuild app:**
```bash
# For Android
flutter build apk

# For iOS
flutter build ios
```

3. **Test on device:**
```bash
flutter run
```

The app icon should now show your Gelmëth logo instead of the default Flutter icon!

---

**Note:** The app name "Gelmëth" is already configured and will appear under the icon on both Android and iOS devices.
