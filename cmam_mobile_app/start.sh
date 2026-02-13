#!/bin/bash

echo "📱 Starting CMAM Mobile App..."
echo ""

cd "$(dirname "$0")"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Get dependencies
echo "📥 Getting Flutter dependencies..."
flutter pub get

echo ""
echo "✅ App ready!"
echo ""
echo "🔧 Available commands:"
echo "  flutter run              - Run on connected device/emulator"
echo "  flutter run -d chrome    - Run in Chrome browser"
echo "  flutter build apk        - Build Android APK"
echo "  flutter build ios        - Build iOS app"
echo ""
echo "📱 Make sure you have:"
echo "  - Android emulator running, OR"
echo "  - iOS simulator running, OR"
echo "  - Physical device connected"
echo ""

# List available devices
echo "📱 Available devices:"
flutter devices

echo ""
read -p "Press Enter to run the app, or Ctrl+C to exit..."

# Run the app
flutter run
