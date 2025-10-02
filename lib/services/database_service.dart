import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bible_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bible_app.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // Bookmark methods
  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    return await db.insert('bookmarks', bookmark.toJson());
  }

  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Bookmark.fromJson(map)).toList();
  }

  Future<int> deleteBookmark(int id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // Reading history methods
  Future<void> saveReadingHistory(
    String translation,
    String book,
    int chapter,
  ) async {
    final db = await database;
    await db.insert('reading_history', {
      'translation': translation,
      'book': book,
      'chapter': chapter,
      'lastRead': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReadingHistory() async {
    final db = await database;
    return await db.query(
      'reading_history',
      orderBy: 'lastRead DESC',
      limit: 10,
    );
  }
  // Add to DatabaseService class

  Future<void> saveDownloadedContent(DownloadedContent content) async {
    final db = await database;
    await db.insert('downloaded_content', content.toJson());
  }

  Future<List<DownloadedContent>> getDownloadedContent() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'downloaded_content',
      orderBy: 'downloadedAt DESC',
    );
    return maps.map((map) => DownloadedContent.fromJson(map)).toList();
  }

  Future<int> deleteDownloadedContent(int id) async {
    final db = await database;
    return await db.delete(
      'downloaded_content',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update the _createDatabase method to include downloaded_content table
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE bookmarks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      translation TEXT NOT NULL,
      book TEXT NOT NULL,
      chapter INTEGER NOT NULL,
      verse INTEGER NOT NULL,
      note TEXT,
      createdAt INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE reading_history(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      translation TEXT NOT NULL,
      book TEXT NOT NULL,
      chapter INTEGER NOT NULL,
      lastRead INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE downloaded_content(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      translation TEXT NOT NULL,
      book TEXT NOT NULL,
      chapter INTEGER,
      content TEXT NOT NULL,
      downloadedAt INTEGER NOT NULL,
      size INTEGER NOT NULL
    )
  ''');
  }
}
