import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_noj/city.dart';
import 'package:weather_noj/forecast.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  late Database db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<void> initDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase(join(path, 'City.db'), onCreate: (db, version) {
      db.execute('''
CREATE TABLE CityInfo (
  Id INTEGER PRIMARY KEY AUTOINCREMENT,
  City TEXT NOT NULL,
  State TEXT NOT NULL,
  Latitude REAL NOT NULL,
  Longitude REAL NOT NULL,
  GridId TEXT NOT NULL,
  GridX INTEGER NOT NULL,
  GridY INTEGER NOT NULL,
  Time INTEGER NOT NULL
)
      ''');
      db.execute('''
CREATE TABLE CityForecast (
  Id INTEGER PRIMARY KEY,
  Temperature INTEGER NOT NULL,
  ProbOfPrecipitation INTEGER NOT NULL,
  Humidity INTEGER NOT NULL,
  WindSpeed INTEGER NOT NULL,
  WindDirection TEXT NOT NULL,
  DailyForecast TEXT NOT NULL,
  HourlyForecast TEXT NOT NULL,
  EndTime INTEGER NOT NULL,
  UpdateTime INTEGER NOT NULL,
  CheckedTime INTEGER NOT NULL
)
      ''');
    }, version: 2);
  }

  Future<int> insertCityInfo(CityInfoCompanion cityInfoCompanion) async {
    int result = await db.insert(
      'CityInfo',
      cityInfoCompanion.toMap(),
    );
    return result;
  }

  Future<int> updateCityInfo(CityInfo cityInfo) async {
    int result = await db.update(
      'CityInfo',
      cityInfo.toMap(),
      where: 'Id = ?',
      whereArgs: [cityInfo.id],
    );
    return result;
  }

  Future<List<CityInfo>> getCityInfos() async {
    final List<Map<String, dynamic>> maps = await db.query('CityInfo');

    return List.generate(
      maps.length,
      (i) => CityInfo.fromMap(maps[i]),
    );
  }

  Future<(CityInfo?, ExceptionType?)> getCityInfo(int id) async {
    final List<Map<String, dynamic>> map = await db.query(
      'CityInfo',
      where: 'Id = ?',
      whereArgs: [id],
    );
    switch (map.length) {
      case 0:
        return (null, ExceptionType.cityInfoEmpty);
      case 1:
        return (CityInfo.fromMap(map[0]), null);
      default:
        return (null, ExceptionType.nonUniqueId);
    }
  }

  Future<int> insertCityForecast(
    int id,
    ForecastInfo forecastWeek,
    ForecastInfo forecastHourly,
  ) async {
    int result = await db.insert(
      'CityForecast',
      CityForecast(
        id: id,
        temperature: temperature,
        probOfPrecipitation: probOfPrecipitation,
        humidity: humidity,
        windSpeed: windSpeed,
        windDirection: windDirection,
        dailyForecast: dailyForecast,
        hourlyForecast: hourlyForecast,
        endTime: endTime,
        updateTime: updateTime,
        checkedTime: checkedTime,
      ).toMap(),
    );
    return result;
  }

  Future<(CityForecast?, ExceptionType?)> getCityForecast(int id) async {
    final List<Map<String, dynamic>> map = await db.query(
      'CityForecast',
      where: 'Id = ?',
      whereArgs: [id],
    );
    switch (map.length) {
      case 0:
        return (null, ExceptionType.cityForecastEmpty);
      case 1:
        return (CityForecast.fromMap(map[0]), null);
      default:
        return (null, ExceptionType.nonUniqueId);
    }
  }
}

enum ExceptionType {
  cityInfoEmpty,
  cityForecastEmpty,
  nonUniqueId,
  non200Response,
}
