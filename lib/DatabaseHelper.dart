// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   // Initialize the database
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'aquarium_settings.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute(
//           '''
//           CREATE TABLE settings(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             fishCount INTEGER,
//             speed REAL,
//             color INTEGER
//           )
//           ''',
//         );
//       },
//     );
//   }

//   // Save settings to the database
//   Future<void> saveSettings(int fishCount, double speed, int color) async {
//     final db = await database;
//     var settings = await db.query('settings');
//     if (settings.isEmpty) {
//       await db.insert('settings', {
//         'fishCount': fishCount,
//         'speed': speed,
//         'color': color,
//       });
//     } else {
//       await db.update(
//         'settings',
//         {
//           'fishCount': fishCount,
//           'speed': speed,
//           'color': color,
//         },
//         where: 'id = ?',
//         whereArgs: [1],
//       );
//     }
//   }

//   // Load settings from the database
//   Future<Map<String, dynamic>?> loadSettings() async {
//     final db = await database;
//     var settings = await db.query('settings');
//     if (settings.isNotEmpty) {
//       return settings.first;
//     }
//     return null;
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'settings.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fishCount INTEGER,
            speed REAL,
            color INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  // Save settings into SQLite
  Future<void> saveSettings(int fishCount, double speed, int colorValue) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'fishCount': fishCount,
        'speed': speed,
        'color': colorValue,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Load settings from SQLite
  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query('settings');

    if (settings.isNotEmpty) {
      return settings.first;
    }
    return null;
  }
}
