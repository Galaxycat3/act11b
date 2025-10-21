import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/folder_model.dart';

class FolderRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<List<FolderModel>> getAllFolders() async {
    final db = await dbProvider.database;
    final maps = await db.query('folders', orderBy: 'name');
    return maps.map((m) => FolderModel.fromMap(m)).toList();
  }

  Future<FolderModel?> getFolder(int id) async {
    final db = await dbProvider.database;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return FolderModel.fromMap(maps.first);
  }

  Future<int> insertFolder(FolderModel folder) async {
    final db = await dbProvider.database;
    return await db.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(FolderModel folder) async {
    final db = await dbProvider.database;
    return await db.update('folders', folder.toMap(), where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> deleteFolder(int id) async {
    final db = await dbProvider.database;
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countCardsInFolder(int folderId) async {
    final db = await dbProvider.database;
    final res = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards WHERE folderId = ?', [folderId]));
    return res ?? 0;
  }

  Future<void> updatePreviewImage(int folderId, String? imageUrl) async {
    final db = await dbProvider.database;
    await db.update('folders', {'previewImage': imageUrl}, where: 'id = ?', whereArgs: [folderId]);
  }
}
