import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbMigrationHelper {
  static Future<void> forceUpgrade() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cmam.db');
    
    // Delete old database
    await deleteDatabase(path);
    print('✅ Old database deleted. App will create fresh database on next launch.');
  }
}
