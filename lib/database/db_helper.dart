import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../models/note_model.dart';

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
    String path = join(await getDatabasesPath(), 'fook_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          color INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        priority INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time TEXT NOT NULL,
        duration INTEGER NOT NULL,
        mode TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE streaks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_completed_date TEXT NOT NULL,
        current_streak INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Pre-insert default categories
    await db.insert('categories', {'name': 'University', 'icon': 'school'});
    await db.insert('categories', {'name': 'Home', 'icon': 'home'});
    await db.insert('categories', {'name': 'Personal', 'icon': 'person'});
    await db.insert('categories', {'name': 'Friends', 'icon': 'group'});
  }

  // Task Operations
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'date ASC, time ASC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category Operations
  Future<int> insertCategory(String name, String icon) async {
    Database db = await database;
    return await db.insert('categories', {'name': name, 'icon': icon});
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    Database db = await database;
    return await db.query('categories');
  }

  // Streak Operations
  Future<Map<String, dynamic>?> getStreak() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('streaks', limit: 1);
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> updateStreak(String date, int count) async {
    Database db = await database;
    final streak = await getStreak();
    if (streak == null) {
      await db.insert('streaks', {'last_completed_date': date, 'current_streak': count});
    } else {
      await db.update('streaks', {'last_completed_date': date, 'current_streak': count}, where: 'id = ?', whereArgs: [streak['id']]);
    }
  }

  // Note Operations
  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updatedAt DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> updateNote(Note note) async {
    Database db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllTasks() async {
    Database db = await database;
    await db.delete('tasks');
  }

  Future<void> clearAllNotes() async {
    Database db = await database;
    await db.delete('notes');
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('tasks');
    await db.delete('notes');
    await db.delete('focus_sessions');
    await db.delete('streaks');
    await db.delete('settings');
  }
}
