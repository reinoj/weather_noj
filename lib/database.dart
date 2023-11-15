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

  CityForecast forecastsToCityForecast(
    int id,
    ForecastInfo forecastWeek,
    ForecastInfo forecastHourly,
  ) {
    return CityForecast(
      id: id,
      temperature: forecastWeek.properties.periods[0].temperature,
      probOfPrecipitation:
          forecastWeek.properties.periods[0].probabilityofPrecipitation.value!,
      humidity: forecastWeek.properties.periods[0].relativeHumidity.value!,
      windSpeed: forecastWeek.properties.periods[0].windSpeed,
      windDirection: forecastWeek.properties.periods[0].windDirection,
      dailyForecast:
          forecastWeek.properties.periods.map((e) => e.toJson()).toString(),
      hourlyForecast: forecastHourly.properties.periods
          .sublist(0, 24)
          .map((e) => e.toJson())
          .toString(),
      endTime: DateTime.parse(forecastWeek.properties.periods[0].endTime)
          .millisecondsSinceEpoch,
      updateTime: DateTime.parse(forecastWeek.properties.updated)
          .millisecondsSinceEpoch,
      checkedTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<int> insertCityForecast(
    int id,
    ForecastInfo forecastWeek,
    ForecastInfo forecastHourly,
  ) async {
    int result = await db.insert(
      'CityForecast',
      forecastsToCityForecast(id, forecastWeek, forecastHourly).toMap(),
    );
    return result;
  }

  Future<int> updateCityForecast(
    int id,
    ForecastInfo forecastWeek,
    ForecastInfo forecastHourly,
  ) async {
    int result = await db.update(
      'CityForecast',
      forecastsToCityForecast(id, forecastWeek, forecastHourly).toMap(),
      where: 'Id = ?',
      whereArgs: [id],
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
        CityForecast cityForecast = CityForecast.fromMap(map[0]);
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        // 300,000 ms = 5 min, 900,000 ms = 15 min
        if (currentTime - cityForecast.updateTime > 900000 ||
            currentTime - cityForecast.checkedTime > 300000) {
          (ForecastInfo, ForecastInfo)? forecasts;
          ExceptionType? et;
          (forecasts, et) = await fetchForecast(_databaseHelper, id);
          if (forecasts != null) {
            int cityId =
                await updateCityForecast(id, forecasts.$1, forecasts.$2);
            print(cityId);
            return (
              forecastsToCityForecast(id, forecasts.$1, forecasts.$2),
              null
            );
          } else {
            return (null, et);
          }
        } else {
          return (cityForecast, null);
        }
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
