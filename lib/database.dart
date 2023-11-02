import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_noj/city.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  late Database db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<void> initDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase(join(path, 'city.db'), onCreate: (db, version) {
      db.execute('''
CREATE TABLE CityInfo (
  Id INTEGER PRIMARY KEY AUTOINCREMENT,
  CityName TEXT NOT NULL,
  StateName TEXT NOT NULL,
  GridId TEXT NOT NULL,
  GridX INTEGER NOT NULL,
  GridY INTEGER NOT NULL,
  Time INTEGER NOT NULL
)
      ''');
    }, version: 1);
  }

  Future<int> insertCityInfo(CityInfo cityInfo) async {
    int result = await db.insert('CityInfo', cityInfo.toMap());
    return result;
  }

  Future<int> updateCityInfo(CityInfo cityInfo) async {
    int result = await db.update('CityInfo', cityInfo.toMap(),
        where: 'Id = ?', whereArgs: [cityInfo.id]);
    return result;
  }

  Future<List<CityInfo>> getCityInfos() async {
    final List<Map<String, dynamic>> maps = await db.query('CityInfo');

    return List.generate(maps.length, (i) => CityInfo.fromMap(maps[i]));
  }
}
