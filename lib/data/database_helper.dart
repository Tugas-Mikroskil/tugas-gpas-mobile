import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        uid TEXT PRIMARY KEY,
        name TEXT,
        age INTEGER,
        phoneNumber TEXT,
        gender TEXT,
        address TEXT
      )
    ''');
  }

  Future<User?> getUserByUID(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      'user',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if exists
    );
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'user',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
