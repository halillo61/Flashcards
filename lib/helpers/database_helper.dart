import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE flashcards (
        id $idType,
        setName $textType,
        front $textType,
        back $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE sets (
        id $idType,
        name $textType
      )
    ''');
  }

  Future<int> createSet(String name) async {
    final db = await database;
    final cleanedName = name.replaceAll(RegExp(r'\s+'), ' ').trim(); // Boşluk hatalarını düzelt
    return await db.insert(
      'sets', // ✅ Tabloyu "sets" olarak düzelt
      {'name': cleanedName},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> readSets() async {
    final db = await instance.database;
    return await db.query('sets');
  }

  Future<int> createFlashcard(Map<String, dynamic> flashcard) async {
    final db = await instance.database;
    return await db.insert('flashcards', flashcard);
  }

  Future<List<Map<String, dynamic>>> readFlashcardsBySet(String setName) async {
    final db = await instance.database;
    return await db.query('flashcards', where: 'setName = ?', whereArgs: [setName]);
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSet(String setName) async {
    final db = await instance.database;
    
    await db.delete("flashcards", where: "setName = ?", whereArgs: [setName]); // ✅ Önce flashcard'ları sil
    return await db.delete("sets", where: "name = ?", whereArgs: [setName]); // ✅ Sonra seti sil
  }

  Future<int> updateSet(int id, String newName, String oldName) async {
    final db = await database;

    // `sets` tablosundaki ismi güncelle
    await db.update(
      'sets',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );

    // `flashcards` tablosundaki eski setName değerlerini güncelle
    await db.update(
      'flashcards',
      {'setName': newName},
      where: 'setName = ?',
      whereArgs: [oldName],
    );

    return 1;
  }

  Future<int> countWordsInSet(String setName) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flashcards WHERE setName = ?',
      [setName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
