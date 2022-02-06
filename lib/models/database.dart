import 'dart:async';
import 'package:path/path.dart';
import 'package:route_r_dam/models/filter.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;
  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('places.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Future _dropDb(Database db) async {
  //   await db.execute("DROP TABLE IF EXISTS places");
  // }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE places (
      _id INTEGER PRIMARY KEY AUTOINCREMENT,
      nickname TEXT NOT NULL,
      address TEXT NOT NULL,
      categories TEXT, 
      latitude REAL NOT NULL,
      longitude REAL NOT NULL
    )
    ''');
  }

  Future<Place> create(Place place) async {
    final db = await instance.database;
    final id = await db.insert('places', place.toMap());
    return place.copy(id: id);
  }

  Future<Place> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'places',
      columns: [
        '_id',
        'nickname',
        'address',
        'categories',
        'latitude',
        'longitude'
      ],
      where: '_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Place.fromMap(maps.first);
    } else {
      throw Exception('id $id não foi encontrado');
    }
  }

  Future<List<Place>> readAll() async {
    final db = await instance.database;
    final orderBy = 'nickname ASC';
    final result = await db.query('places', orderBy: orderBy);
    return result.map((e) => Place.fromMap(e)).toList();
  }

  Future<List<Place>> readFirst20() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT * FROM places LIMIT 20');
    return result.map((e) => Place.fromMap(e)).toList();
  }

  Future<List<Place>> readFiltered(List<Filter> filters) async {
    String query =
        'SELECT * FROM places where ' + _turnFilterIntoSql(filters.first);
    if (filters.length > 1) {
      for (Filter filter in filters.sublist(1)) {
        query += ' OR ' + _turnFilterIntoSql(filter);
      }
    }

    final db = await instance.database;
    final result = await db.rawQuery(query);

    return result.map((e) => Place.fromMap(e)).toList();
  }

  String _turnFilterIntoSql(Filter filter) {
    String filterSql = filter.columnName +
        filter.conector +
        "'%" +
        filter.filterArgs.first +
        "%'";
    if (filter.filterArgs.length > 1) {
      for (String arg in filter.filterArgs.sublist(1)) {
        filterSql += ' OR ' +
            filter.columnName +
            filter.conector +
            "'%" +
            arg +
            "%'" +
            ' ';
      }
    }

    return filterSql;
  }

  Future<int> update(Place place) async {
    final db = await instance.database;

    return db.update(
      'places',
      place.toMap(),
      where: '_id = ?',
      whereArgs: [place.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'places',
      where: '_id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
