import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/new_home_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/history_screen.dart';
import 'screens/referrals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(const CMAMApp());
}

class CMAMApp extends StatefulWidget {
  const CMAMApp({super.key});

  @override
  State<CMAMApp> createState() => _CMAMAppState();
}

class _CMAMAppState extends State<CMAMApp> {
  bool _isDarkMode = false;
  double _textSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _textSize = prefs.getDouble('text_size') ?? 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gelmäth - CMAM Care Pathway',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: const Color(0xFF0E4D34),
        scaffoldBackgroundColor: _isDarkMode ? Colors.grey[900] : const Color(0xFFF4F7F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E4D34),
          primary: const Color(0xFF0E4D34),
          secondary: const Color(0xFF2ECC71),
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16 * _textSize),
          bodyMedium: TextStyle(fontSize: 14 * _textSize),
          bodySmall: TextStyle(fontSize: 12 * _textSize),
          titleLarge: TextStyle(fontSize: 20 * _textSize),
          titleMedium: TextStyle(fontSize: 16 * _textSize),
          titleSmall: TextStyle(fontSize: 14 * _textSize),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E4D34),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E4D34),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0E4D34), width: 2),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0E4D34),
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: SettingsProvider(
        onSettingsChanged: _loadSettings,
        child: const AuthCheck(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/assessment': (context) => const AssessmentScreen(),
        '/referrals': (context) => const ReferralsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }

  Future<bool> _checkLogin() async {
    return await AuthService.isLoggedIn();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AssessmentScreen(),
    const HistoryScreen(),
    const ReferralsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFF0E4D34),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
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
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                ),
              ],
            )
          : AppBar(
              title: Text(_getTitle()),
              automaticallyImplyLeading: false,
            ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Referrals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 1:
        return 'New Assessment';
      case 2:
        return 'Assessment History';
      case 3:
        return 'Referrals';
      case 4:
        return 'Settings';
      default:
        return 'Gelmäth';
    }
  }
}

class SettingsProvider extends InheritedWidget {
  final VoidCallback onSettingsChanged;

  const SettingsProvider({
    super.key,
    required this.onSettingsChanged,
    required super.child,
  });

  static SettingsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsProvider>();
  }

  @override
  bool updateShouldNotify(SettingsProvider oldWidget) => true;
}
