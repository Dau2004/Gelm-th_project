class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Title & Branding
      'app_title': 'Gelmäth - CMAM Care Pathway',
      'app_name': 'Gelmäth',
      'app_tagline': 'Protecting Every Child',
      'cmam_guidelines': 'CMAM Guidelines - South Sudan 2017',
      'ministry_who': 'Ministry of Health • WHO',
      
      // Navigation
      'home': 'Home',
      'new': 'New',
      'history': 'History',
      'referrals': 'Referrals',
      'settings': 'Settings',
      
      // Authentication
      'login': 'Login',
      'logout': 'Logout',
      'username': 'Username',
      'password': 'Password',
      'welcome_back': 'Welcome Back',
      'logout_confirm': 'Are you sure you want to logout?',
      'please_enter_credentials': 'Please enter username and password',
      'invalid_credentials': 'Invalid username or password',
      
      // Home Screen
      'new_assessment': 'New Assessment',
      'screen_child_malnutrition': 'Screen child for malnutrition',
      'assessment_history': 'Assessment History',
      'view_past_assessments': 'View past assessments',
      'offline_first_sync': 'Offline-first • Auto-sync when online',
      
      // Assessment Form
      'child_id': 'Child ID',
      'child_id_auto': 'Child ID (Auto-generated)',
      'state': 'State',
      'health_facility': 'Health Facility',
      'your_name_chw': 'Your Name (CHW)',
      'enter_full_name': 'Enter your full name',
      'your_phone_number': 'Your Phone Number',
      'sex': 'Sex',
      'boy': 'Boy',
      'girl': 'Girl',
      'age_months': 'Age (months)',
      'age_range': '3-60',
      'age_validation': 'Age must be 3-60 months',
      'muac_mm': 'MUAC (mm)',
      'muac_range': '90-200',
      'muac_validation': 'MUAC must be 90-200 mm',
      'edema': 'Edema',
      'edema_bilateral': 'Edema (bilateral pitting)',
      'appetite': 'Appetite',
      'appetite_test': 'Appetite Test',
      'danger_signs': 'Danger Signs',
      'danger_signs_complications': 'Danger Signs / Complications',
      'calculate_pathway': 'Calculate Pathway',
      'required': 'Required',
      
      // Options
      'male': 'Male',
      'female': 'Female',
      'good': 'Good',
      'poor': 'Poor',
      'failed': 'Failed',
      'yes': 'Yes',
      'no': 'No',
      
      // Quality Check
      'measurement_quality_issue': 'Measurement Quality Issue',
      'near_threshold': 'Near Threshold',
      'details': 'Details:',
      'ok_recheck': 'OK, I\'ll Re-check',
      'remeasure': 'Re-measure',
      'continue': 'Continue',
      
      // Result Screen
      'assessment_result': 'Assessment Result',
      'child_information': 'Child Information',
      'clinical_assessment': 'Clinical Assessment',
      'recommendation': 'Recommendation',
      'reasoning': 'Reasoning',
      'muac_zscore': 'MUAC Z-Score',
      'status': 'Status',
      'programme': 'Programme',
      'confidence': 'Confidence',
      'refer_to_doctor': 'Refer to Doctor',
      'create_referral': 'Create Referral',
      'complete_assessment': 'Complete Assessment',
      'back_to_home': 'Back to Home',
      'synced_to_dashboard': 'OK Assessment synced to MoH Dashboard',
      'sync_failed_login': 'WARNING Sync failed - Please login first',
      
      // History Screen
      'no_assessments_yet': 'No assessments yet',
      'clear_history': 'Clear History',
      'clear_history_confirm': 'Are you sure you want to delete all assessment records? This action cannot be undone.',
      'delete_all': 'Delete All',
      'history_cleared': 'History cleared successfully',
      'synced': 'Synced',
      'local': 'Local',
      
      // Settings Screen
      'community_health_worker': 'Community Health Worker',
      'app_settings': 'App Settings',
      'dark_mode': 'Dark Mode',
      'switch_theme': 'Switch between light and dark theme',
      'theme_updated': 'Theme updated',
      'text_size': 'Text Size',
      'current': 'Current',
      'language': 'Language',
      'data_sync': 'Data Sync',
      'sync_assessments': 'Sync Assessments',
      'upload_unsynced': 'Upload unsynced data to server',
      'app_information': 'App Information',
      'version': 'Version',
      'guidelines': 'Guidelines',
      'who_standards': 'WHO Standards',
      'sign_out_account': 'Sign out of your account',
      
      // Common
      'submit': 'Submit',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      
      // Clinical Status
      'sam': 'SAM',
      'mam': 'MAM',
      'healthy': 'Healthy',
      'unknown': 'Unknown',
      'none': 'None',
      
      // Pathways
      'sc_itp': 'SC-ITP',
      'otp': 'OTP',
      'tsfp': 'TSFP',
      
      // Misc
      'total': 'Total',
      'months': 'months',
      'mm': 'mm',
      'cm': 'cm',
    },
    'ar': {
      // App Title & Branding
      'app_title': 'جلمث - مسار رعاية CMAM',
      'app_name': 'جلمث',
      'app_tagline': 'حماية كل طفل',
      'cmam_guidelines': 'إرشادات CMAM - جنوب السودان 2017',
      'ministry_who': 'وزارة الصحة • منظمة الصحة العالمية',
      
      // Navigation
      'home': 'الرئيسية',
      'new': 'جديد',
      'history': 'السجل',
      'referrals': 'الإحالات',
      'settings': 'الإعدادات',
      
      // Authentication
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'welcome_back': 'مرحباً بعودتك',
      'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'please_enter_credentials': 'الرجاء إدخال اسم المستخدم وكلمة المرور',
      'invalid_credentials': 'اسم المستخدم أو كلمة المرور غير صحيحة',
      
      // Home Screen
      'new_assessment': 'تقييم جديد',
      'screen_child_malnutrition': 'فحص الطفل لسوء التغذية',
      'assessment_history': 'سجل التقييمات',
      'view_past_assessments': 'عرض التقييمات السابقة',
      'offline_first_sync': 'يعمل بدون إنترنت • مزامنة تلقائية عند الاتصال',
      
      // Assessment Form
      'child_id': 'رقم الطفل',
      'child_id_auto': 'رقم الطفل (تلقائي)',
      'state': 'الولاية',
      'health_facility': 'المرفق الصحي',
      'your_name_chw': 'اسمك (عامل صحي)',
      'enter_full_name': 'أدخل اسمك الكامل',
      'your_phone_number': 'رقم هاتفك',
      'sex': 'الجنس',
      'boy': 'ولد',
      'girl': 'بنت',
      'age_months': 'العمر (بالأشهر)',
      'age_range': '3-60',
      'age_validation': 'يجب أن يكون العمر بين 3-60 شهراً',
      'muac_mm': 'محيط منتصف الذراع (ملم)',
      'muac_range': '90-200',
      'muac_validation': 'يجب أن يكون محيط الذراع بين 90-200 ملم',
      'edema': 'الوذمة',
      'edema_bilateral': 'الوذمة (ثنائية الجانب)',
      'appetite': 'الشهية',
      'appetite_test': 'اختبار الشهية',
      'danger_signs': 'علامات الخطر',
      'danger_signs_complications': 'علامات الخطر / المضاعفات',
      'calculate_pathway': 'حساب المسار',
      'required': 'مطلوب',
      
      // Options
      'male': 'ذكر',
      'female': 'أنثى',
      'good': 'جيدة',
      'poor': 'ضعيفة',
      'failed': 'فاشل',
      'yes': 'نعم',
      'no': 'لا',
      
      // Quality Check
      'measurement_quality_issue': 'مشكلة في جودة القياس',
      'near_threshold': 'قريب من الحد',
      'details': 'التفاصيل:',
      'ok_recheck': 'حسناً، سأعيد الفحص',
      'remeasure': 'إعادة القياس',
      'continue': 'متابعة',
      
      // Result Screen
      'assessment_result': 'نتيجة التقييم',
      'child_information': 'معلومات الطفل',
      'clinical_assessment': 'التقييم السريري',
      'recommendation': 'التوصية',
      'reasoning': 'التفسير',
      'muac_zscore': 'درجة Z لمحيط الذراع',
      'status': 'الحالة',
      'programme': 'البرنامج',
      'confidence': 'الثقة',
      'refer_to_doctor': 'إحالة إلى الطبيب',
      'create_referral': 'إنشاء إحالة',
      'complete_assessment': 'إكمال التقييم',
      'back_to_home': 'العودة للرئيسية',
      'synced_to_dashboard': 'OK تم مزامنة التقييم مع لوحة وزارة الصحة',
      'sync_failed_login': 'WARNING فشلت المزامنة - الرجاء تسجيل الدخول أولاً',
      
      // History Screen
      'no_assessments_yet': 'لا توجد تقييمات بعد',
      'clear_history': 'مسح السجل',
      'clear_history_confirm': 'هل أنت متأكد من حذف جميع سجلات التقييم؟ لا يمكن التراجع عن هذا الإجراء.',
      'delete_all': 'حذف الكل',
      'history_cleared': 'تم مسح السجل بنجاح',
      'synced': 'متزامن',
      'local': 'محلي',
      
      // Settings Screen
      'community_health_worker': 'عامل صحي مجتمعي',
      'app_settings': 'إعدادات التطبيق',
      'dark_mode': 'الوضع الداكن',
      'switch_theme': 'التبديل بين الوضع الفاتح والداكن',
      'theme_updated': 'تم تحديث المظهر',
      'text_size': 'حجم النص',
      'current': 'الحالي',
      'language': 'اللغة',
      'data_sync': 'مزامنة البيانات',
      'sync_assessments': 'مزامنة التقييمات',
      'upload_unsynced': 'رفع البيانات غير المتزامنة إلى الخادم',
      'app_information': 'معلومات التطبيق',
      'version': 'الإصدار',
      'guidelines': 'الإرشادات',
      'who_standards': 'معايير منظمة الصحة العالمية',
      'sign_out_account': 'تسجيل الخروج من حسابك',
      
      // Common
      'submit': 'إرسال',
      'cancel': 'إلغاء',
      'ok': 'حسناً',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'close': 'إغلاق',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      
      // Clinical Status
      'sam': 'سوء التغذية الحاد الشديد',
      'mam': 'سوء التغذية الحاد المتوسط',
      'healthy': 'سليم',
      'unknown': 'غير معروف',
      'none': 'لا شيء',
      
      // Pathways
      'sc_itp': 'SC-ITP',
      'otp': 'OTP',
      'tsfp': 'TSFP',
      
      // Misc
      'total': 'المجموع',
      'months': 'أشهر',
      'mm': 'ملم',
      'cm': 'سم',
    },
  };

  String translate(String key) => _localizedValues[languageCode]?[key] ?? key;
}
