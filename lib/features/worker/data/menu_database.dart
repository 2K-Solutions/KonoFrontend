import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final menuDatabaseProvider = Provider<MenuDatabase>((ref) => MenuDatabase());

class MenuDatabase {
  static const _table = 'menu_items';

  Future<Database>? _database;

  Future<Database> get _db => _database ??= _open();

  Future<Database> _open() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kono_menu.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE $_table (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          search_name TEXT NOT NULL,
          price REAL NOT NULL,
          is_drink INTEGER NOT NULL
        )
      '''),
    );
  }

  // Replaces the whole local menu with the given items in a single transaction.
  Future<void> replaceAll(List<MenuItem> items) async {
    final db = await _db;
    await db.transaction((txn) async {
      final batch = txn.batch()..delete(_table);
      for (final item in items) {
        batch.insert(_table, {
          'id': item.id,
          'name': item.name,
          // Dart lowercasing handles č, ć, š, ž, đ, which SQLite's LIKE doesn't.
          'search_name': item.name.toLowerCase(),
          'price': item.price,
          'is_drink': item.isDrink ? 1 : 0,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<MenuItem>> search({required MenuCategory category, String query = ''}) async {
    final db = await _db;
    final pattern = query.toLowerCase().replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
    final rows = await db.query(
      _table,
      where: r"is_drink = ? AND search_name LIKE ? ESCAPE '\'",
      whereArgs: [category == MenuCategory.drinks ? 1 : 0, '%$pattern%'],
      orderBy: 'search_name',
    );
    return rows.map(_fromRow).toList();
  }

  Future<Map<String, MenuItem>> getByIds(Iterable<String> ids) async {
    final idList = ids.toSet().toList();
    if (idList.isEmpty) return const {};
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'id IN (${List.filled(idList.length, '?').join(', ')})',
      whereArgs: idList,
    );
    return {for (final item in rows.map(_fromRow)) item.id: item};
  }

  MenuItem _fromRow(Map<String, Object?> row) {
    return MenuItem(
      id: row['id'] as String,
      name: row['name'] as String,
      price: row['price'] as double,
      isDrink: row['is_drink'] == 1,
    );
  }

  Future<void> clear() async {
    final db = await _db;
    await db.delete(_table);
  }
}
