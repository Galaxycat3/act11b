import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  static const int _version = 1;
  static const String _dbName = 'card_folders.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        previewImage TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        imageBytes TEXT,
        folderId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(folderId) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    await _prepopulate(db);
  }

  Future _prepopulate(Database db) async {
    final now = DateTime.now().toIso8601String();

    final suits = ['Hearts','Spades','Diamonds','Clubs'];
    for (final s in suits) {
      await db.insert('folders', {
        'name': s,
        'previewImage': null,
        'createdAt': now
      });
    }

    // sample image URLs - we'll cycle through these (12 images)
    final sampleImages = List<String>.generate(12, (i) => 'https://picsum.photos/seed/card${i+1}/400/300');

    final ranks = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];

    int cardIndex = 0;
    for (final s in suits) {
      for (final r in ranks) {
        final name = '$r of $s';
        final imageUrl = sampleImages[cardIndex % sampleImages.length];
        await db.insert('cards', {
          'name': name,
          'suit': s,
          'imageUrl': imageUrl,
          'imageBytes': null,
          'folderId': null, // unassigned initially
          'createdAt': now
        });
        cardIndex++;
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
