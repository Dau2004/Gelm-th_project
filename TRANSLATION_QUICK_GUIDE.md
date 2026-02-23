# Quick Implementation Guide - Remaining Screen Translations

## Assessment Screen Translation

### Step 1: Add imports
```dart
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';
import '../l10n/app_localizations.dart';
```

### Step 2: Get locale in build method
```dart
@override
Widget build(BuildContext context) {
  final locale = Provider.of<LocaleProvider>(context).locale;
  final l10n = AppLocalizations(locale.languageCode);
  
  // ... rest of code
}
```

### Step 3: Replace hardcoded strings

**Before:**
```dart
const Text('State')
```

**After:**
```dart
Text(l10n.translate('state'))
```

### Key Translations Needed:
- `child_id_auto` → "Child ID (Auto-generated)" / "رقم الطفل (تلقائي)"
- `state` → "State" / "الولاية"
- `health_facility` → "Health Facility" / "المرفق الصحي"
- `your_name_chw` → "Your Name (CHW)" / "اسمك (عامل صحي)"
- `your_phone_number` → "Your Phone Number" / "رقم هاتفك"
- `sex` → "Sex" / "الجنس"
- `boy` → "Boy" / "ولد"
- `girl` → "Girl" / "بنت"
- `age_months` → "Age (months)" / "العمر (بالأشهر)"
- `muac_mm` → "MUAC (mm)" / "محيط منتصف الذراع (ملم)"
- `edema_bilateral` → "Edema (bilateral pitting)" / "الوذمة (ثنائية الجانب)"
- `appetite_test` → "Appetite Test" / "اختبار الشهية"
- `danger_signs_complications` → "Danger Signs / Complications" / "علامات الخطر / المضاعفات"
- `calculate_pathway` → "Calculate Pathway" / "حساب المسار"
- `required` → "Required" / "مطلوب"
- `age_validation` → "Age must be 3-60 months" / "يجب أن يكون العمر بين 3-60 شهراً"
- `muac_validation` → "MUAC must be 90-200 mm" / "يجب أن يكون محيط الذراع بين 90-200 ملم"

## Result Screen Translation

### Key Translations Needed:
- `assessment_result` → "Assessment Result" / "نتيجة التقييم"
- `child_information` → "Child Information" / "معلومات الطفل"
- `clinical_assessment` → "Clinical Assessment" / "التقييم السريري"
- `recommendation` → "Recommendation" / "التوصية"
- `reasoning` → "Reasoning" / "التفسير"
- `muac_zscore` → "MUAC Z-Score" / "درجة Z لمحيط الذراع"
- `status` → "Status" / "الحالة"
- `programme` → "Programme" / "البرنامج"
- `confidence` → "Confidence" / "الثقة"
- `refer_to_doctor` → "Refer to Doctor" / "إحالة إلى الطبيب"
- `create_referral` → "Create Referral" / "إنشاء إحالة"
- `complete_assessment` → "Complete Assessment" / "إكمال التقييم"
- `back_to_home` → "Back to Home" / "العودة للرئيسية"
- `synced_to_dashboard` → "✓ Assessment synced to MoH Dashboard" / "✓ تم مزامنة التقييم مع لوحة وزارة الصحة"
- `sync_failed_login` → "⚠ Sync failed - Please login first" / "⚠ فشلت المزامنة - الرجاء تسجيل الدخول أولاً"

## Example: Translating a Dialog

**Before:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Logout'),
    content: const Text('Are you sure you want to logout?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Logout'),
      ),
    ],
  ),
);
```

**After:**
```dart
Future<void> _showLogoutDialog() async {
  final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
  final l10n = AppLocalizations(locale.languageCode);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.translate('logout')),
      content: Text(l10n.translate('logout_confirm')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.translate('logout')),
        ),
      ],
    ),
  );
}
```

## Example: Translating SnackBar Messages

**Before:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Assessment saved successfully')),
);
```

**After:**
```dart
final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
final l10n = AppLocalizations(locale.languageCode);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.translate('assessment_saved'))),
);
```

## Example: Translating Form Validation

**Before:**
```dart
validator: (v) {
  if (v?.isEmpty ?? true) return 'Required';
  final age = int.tryParse(v!);
  if (age == null || age < 3 || age > 60) {
    return 'Age must be 3-60 months';
  }
  return null;
}
```

**After:**
```dart
validator: (v) {
  if (v?.isEmpty ?? true) return l10n.translate('required');
  final age = int.tryParse(v!);
  if (age == null || age < 3 || age > 60) {
    return l10n.translate('age_validation');
  }
  return null;
}
```

## Common Patterns

### 1. Static Text → Dynamic Translation
```dart
// Before
const Text('Hello World')

// After
Text(l10n.translate('hello_world'))
```

### 2. String Interpolation
```dart
// Before
Text('Age: $age months')

// After
Text('${l10n.translate('age')}: $age ${l10n.translate('months')}')
```

### 3. Conditional Text
```dart
// Before
Text(sex == 'M' ? 'Boy' : 'Girl')

// After
Text(sex == 'M' ? l10n.translate('boy') : l10n.translate('girl'))
```

### 4. Button Labels
```dart
// Before
ElevatedButton(
  onPressed: _submit,
  child: const Text('Submit'),
)

// After
ElevatedButton(
  onPressed: _submit,
  child: Text(l10n.translate('submit')),
)
```

## Testing Checklist

After implementing translations:

- [ ] Switch to Arabic in Settings
- [ ] Navigate through all screens
- [ ] Check text alignment (RTL for Arabic)
- [ ] Verify no text overflow
- [ ] Test all buttons and actions
- [ ] Check dialogs and popups
- [ ] Verify error messages
- [ ] Test form validation messages
- [ ] Check SnackBar messages
- [ ] Verify tooltips

## Tips

1. **Always use `listen: false` in async functions:**
   ```dart
   final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
   ```

2. **Get locale at the start of build method:**
   ```dart
   @override
   Widget build(BuildContext context) {
     final locale = Provider.of<LocaleProvider>(context).locale;
     final l10n = AppLocalizations(locale.languageCode);
     // ... rest of code
   }
   ```

3. **For StatefulWidget, get locale in each method that needs it:**
   ```dart
   Future<void> _someMethod() async {
     final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
     final l10n = AppLocalizations(locale.languageCode);
     // Use l10n.translate() here
   }
   ```

4. **All translation keys are already in `app_localizations.dart`** - just use them!

## Quick Reference: Available Translation Keys

All these keys are already defined in `app_localizations.dart`:

**Authentication:**
- login, logout, username, password, welcome_back, logout_confirm

**Navigation:**
- home, new, history, referrals, settings

**Assessment:**
- child_id, sex, age_months, muac_mm, edema, appetite, danger_signs
- boy, girl, good, poor, yes, no

**Settings:**
- app_settings, dark_mode, text_size, language, data_sync, version

**Clinical:**
- sam, mam, healthy, unknown, sc_itp, otp, tsfp

**Common:**
- submit, cancel, ok, save, delete, edit, close, loading, error, success

**And 70+ more keys!** Check `app_localizations.dart` for the complete list.

---

**Need help?** All translation keys are documented in:
- `/lib/l10n/app_localizations.dart` - Full translation dictionary
- `/ARABIC_TRANSLATION_IMPLEMENTATION.md` - Complete implementation guide
