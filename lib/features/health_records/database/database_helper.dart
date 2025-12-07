import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('healthmate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dailyStepsGoal INTEGER NOT NULL,
          dailyCaloriesGoal INTEGER NOT NULL,
          dailyWaterGoal INTEGER NOT NULL,
          weeklyStepsGoal INTEGER NOT NULL,
          weeklyCaloriesGoal INTEGER NOT NULL,
          weeklyWaterGoal INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          isDarkMode INTEGER NOT NULL DEFAULT 0,
          themeColor TEXT NOT NULL DEFAULT 'teal',
          notificationsEnabled INTEGER NOT NULL DEFAULT 1,
          waterReminders INTEGER NOT NULL DEFAULT 1,
          dailyLogReminders INTEGER NOT NULL DEFAULT 1,
          goalAlerts INTEGER NOT NULL DEFAULT 1,
          reminderTime TEXT,
          height REAL,
          weight REAL,
          updatedAt TEXT
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE health_records (
        id $idType,
        date $textType,
        steps $integerType,
        calories $integerType,
        water $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE health_goals (
        id $idType,
        dailyStepsGoal $integerType,
        dailyCaloriesGoal $integerType,
        dailyWaterGoal $integerType,
        weeklyStepsGoal $integerType,
        weeklyCaloriesGoal $integerType,
        weeklyWaterGoal $integerType,
        createdAt $textType,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        id $idType,
        isDarkMode INTEGER NOT NULL DEFAULT 0,
        themeColor $textType DEFAULT 'teal',
        notificationsEnabled INTEGER NOT NULL DEFAULT 1,
        waterReminders INTEGER NOT NULL DEFAULT 1,
        dailyLogReminders INTEGER NOT NULL DEFAULT 1,
        goalAlerts INTEGER NOT NULL DEFAULT 1,
        reminderTime TEXT,
        height REAL,
        weight REAL,
        updatedAt TEXT
      )
    ''');

    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    var dummyRecords = [
      {
        'date': '2025-11-28',
        'steps': 7823,
        'calories': 412,
        'water': 1800,
      },
      {
        'date': '2025-11-29',
        'steps': 9456,
        'calories': 503,
        'water': 2150,
      },
      {
        'date': '2025-12-03',
        'steps': 6234,
        'calories': 378,
        'water': 1600,
      },
    ];

    for (var record in dummyRecords) {
      await db.insert('health_records', record);
    }
  }

  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> getAllHealthRecords() async {
    var db = await database;
    var result = await db.query('health_records', orderBy: 'date DESC');
    var records = result.map((map) => HealthRecord.fromMap(map)).toList();
    return records;
  }

  Future<HealthRecord?> getHealthRecordById(int id) async {
    final db = await database;
    var maps = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return HealthRecord.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<HealthRecord>> getHealthRecordsByDate(String date) async {
    var db = await database;
    final result = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  Future<List<HealthRecord>> getTodayHealthRecords(String today) async {
    return await getHealthRecordsByDate(today);
  }

  Future<List<HealthRecord>> getHealthRecordsByDateRange(
      String startDate, String endDate) async {
    var db = await database;
    var result = await db.query(
      'health_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((map) => HealthRecord.fromMap(map)).toList();
  }

  Future<int> updateHealthRecord(HealthRecord record) async {
    var db = await database;
    return db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteHealthRecord(int id) async {
    final db = await database;
    return db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllHealthRecords() async {
    final db = await database;
    return await db.delete('health_records');
  }

  Future<Map<String, int>> getStatsByDate(String date) async {
    var records = await getHealthRecordsByDate(date);
    int steps = 0;
    int calories = 0;
    int water = 0;

    for (var r in records) {
      steps += r.steps;
      calories += r.calories;
      water += r.water;
    }

    return {
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
