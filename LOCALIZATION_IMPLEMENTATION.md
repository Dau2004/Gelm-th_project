# Localization Implementation

## Overview
Added English and Arabic language support with language switcher in Settings.

## Files Created

1. **lib/services/locale_provider.dart** - Manages language state
2. **lib/l10n/app_localizations.dart** - Translation strings

## Files Modified

1. **lib/main.dart** - Added Provider and locale support
2. **lib/screens/settings_screen.dart** - Added language dropdown

## Usage

### Change Language
1. Open app
2. Go to Settings tab
3. Find "Language" option
4. Select English or العربية from dropdown
5. App updates immediately

## Translations Included

- Navigation: Home, New, History, Referrals, Settings
- Actions: Login, Logout, Submit, Cancel, Save
- Assessment: Child ID, Sex, Age, MUAC, Edema, Appetite
- Status: SAM, MAM, Total, Pending, Completed
- Settings: Dark Mode, Text Size, Language

## Adding More Translations

Edit `lib/l10n/app_localizations.dart`:

```dart
'en': {
  'new_key': 'English text',
},
'ar': {
  'new_key': 'النص العربي',
},
```

## Testing

- [x] Switch to Arabic - UI updates
- [x] Switch to English - UI updates  
- [x] Language persists after app restart
- [x] Bottom navigation shows translated labels
- [x] Settings screen shows translated text
