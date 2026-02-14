import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/child_assessment.dart';
import '../models/referral.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cmam.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE assessments ADD COLUMN facility TEXT');
      await db.execute('ALTER TABLE assessments ADD COLUMN state TEXT');
      await db.execute('ALTER TABLE assessments ADD COLUMN county TEXT');
      await db.execute('ALTER TABLE assessments ADD COLUMN chw_name TEXT');
      await db.execute('ALTER TABLE assessments ADD COLUMN chw_phone TEXT');
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE assessments ADD COLUMN chw_notes TEXT');
      } catch (e) {}
      try {
        await db.execute('ALTER TABLE assessments ADD COLUMN chw_signature TEXT');
      } catch (e) {}
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS referrals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          assessment_id TEXT NOT NULL,
          child_id TEXT NOT NULL,
          pathway TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          notes TEXT,
          timestamp TEXT NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE assessments ADD COLUMN chw_username TEXT');
      } catch (e) {}
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id TEXT NOT NULL,
        sex TEXT NOT NULL,
        age_months INTEGER NOT NULL,
        muac_mm INTEGER NOT NULL,
        edema INTEGER NOT NULL,
        appetite TEXT NOT NULL,
        danger_signs INTEGER NOT NULL,
        muac_z_score REAL,
        clinical_status TEXT,
        recommended_pathway TEXT,
        confidence REAL,
        timestamp TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        facility TEXT,
        state TEXT,
        county TEXT,
        chw_name TEXT,
        chw_phone TEXT,
        chw_notes TEXT,
        chw_signature TEXT,
        chw_username TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE referrals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT NOT NULL,
        child_id TEXT NOT NULL,
        pathway TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        notes TEXT,
        timestamp TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> createAssessment(ChildAssessment assessment) async {
    final db = await instance.database;
    return await db.insert('assessments', assessment.toMap());
  }

  Future<List<ChildAssessment>> getAllAssessments() async {
    final db = await instance.database;
    final result = await db.query(
      'assessments',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ChildAssessment.fromMap(map)).toList();
  }

  Future<List<ChildAssessment>> getAssessmentsByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'assessments',
      where: 'chw_username = ?',
      whereArgs: [username],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => ChildAssessment.fromMap(map)).toList();
  }

  Future<List<ChildAssessment>> getUnsyncedAssessments() async {
    final db = await instance.database;
    final result = await db.query(
      'assessments',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => ChildAssessment.fromMap(map)).toList();
  }
  
  Future<void> markAsSynced(int id) async {
    final db = await instance.database;
    await db.update(
      'assessments',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAssessment(ChildAssessment assessment) async {
    final db = await instance.database;
    final map = assessment.toMap();
    final id = map.remove('id');
    
    if (id == null) {
      throw Exception('Cannot update assessment without ID');
    }
    
    return await db.update(
      'assessments',
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAssessment(String id) async {
    final db = await instance.database;
    return await db.delete(
      'assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> createReferral(Referral referral) async {
    final db = await instance.database;
    return await db.insert('referrals', referral.toMap());
  }

  Future<List<Referral>> getAllReferrals() async {
    final db = await instance.database;
    final result = await db.query('referrals', orderBy: 'timestamp DESC');
    return result.map((map) => Referral.fromMap(map)).toList();
  }

  Future<List<Referral>> getUnsyncedReferrals() async {
    final db = await instance.database;
    final result = await db.query(
      'referrals',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return result.map((map) => Referral.fromMap(map)).toList();
  }

  Future<void> markReferralAsSynced(int id) async {
    final db = await instance.database;
    await db.update(
      'referrals',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateReferralStatus(String id, String status) async {
    final db = await instance.database;
    return await db.update(
      'referrals',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
