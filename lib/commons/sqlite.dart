import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Detached {
  final String isDetached;
  final String detachedAt;

  Detached({
    required this.isDetached,
    required this.detachedAt,
  });

  Map<String, dynamic> toMap() {
    return {'isDetached': isDetached, 'detachedAt': detachedAt};
  }

  //DBへの接続
  static Future<Database> get detachedDatabese async {
    final databese = openDatabase(
      join(await getDatabasesPath(), 'detached_database.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE detached(isDetached TEXT PRIMARY KEY, detachedAt TEXT)');
      },
      version: 1,
    );
    return databese;
  }

  //DBへの書き込み
  static Future<void> insertDetached(Detached detached) async {
    final Database db = await detachedDatabese;
    await db.insert(
      'checkAppLifecycle',
      detached.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //データの取得
  static Future<List<Detached>> getDetached() async {
    final Database db = await detachedDatabese;
    final List<Map<String, dynamic>> maps = await db.query('detached');
    return List.generate(maps.length, (index) {
      return Detached(
        isDetached: maps[index]['isDetached'],
        detachedAt: maps[index]['detachedAt'],
      );
    });
  }

  //データの削除
  static Future<void> deleteDetached() async {
    final Database db = await detachedDatabese;
    await db.delete('detached');
  }
}
