class AppConstants {
  // South Sudan States
  static const List<String> states = [
    'Central Equatoria',
    'Eastern Equatoria',
    'Western Equatoria',
    'Jonglei',
    'Unity',
    'Upper Nile',
    'Northern Bahr el Ghazal',
    'Western Bahr el Ghazal',
    'Lakes',
    'Warrap',
  ];

  // Sample Facilities by State
  static const Map<String, List<String>> facilitiesByState = {
    'Central Equatoria': [
      'Juba Teaching Hospital',
      'Juba Military Hospital',
      'Kator Primary Health Care Centre',
      'Munuki Primary Health Care Centre',
      'Gudele Primary Health Care Centre',
    ],
    'Eastern Equatoria': [
      'Torit State Hospital',
      'Kapoeta State Hospital',
      'Magwi Primary Health Care Centre',
    ],
    'Western Equatoria': [
      'Yambio State Hospital',
      'Ezo Primary Health Care Centre',
      'Nzara Primary Health Care Centre',
    ],
    'Jonglei': [
      'Bor State Hospital',
      'Pibor Primary Health Care Centre',
      'Akobo Primary Health Care Centre',
    ],
    'Unity': [
      'Bentiu State Hospital',
      'Rubkona Primary Health Care Centre',
      'Leer Primary Health Care Centre',
    ],
    'Upper Nile': [
      'Malakal Teaching Hospital',
      'Renk Primary Health Care Centre',
      'Kodok Primary Health Care Centre',
    ],
    'Northern Bahr el Ghazal': [
      'Aweil State Hospital',
      'Aweil East Primary Health Care Centre',
    ],
    'Western Bahr el Ghazal': [
      'Wau Teaching Hospital',
      'Raja Primary Health Care Centre',
    ],
    'Lakes': [
      'Rumbek State Hospital',
      'Yirol Primary Health Care Centre',
    ],
    'Warrap': [
      'Kuajok State Hospital',
      'Tonj Primary Health Care Centre',
    ],
  };

  static List<String> getFacilities(String state) {
    return facilitiesByState[state] ?? [];
  }
}
