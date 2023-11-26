import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_noj/city.dart';
import 'package:weather_noj/exceptions.dart';
import 'package:weather_noj/forecast.dart';
import 'package:weather_noj/points.dart';

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
      String dailyString = List.generate(14, (index) => index)
          .map((e) => 'Day${e ~/ 2}_${e % 2} INTEGER NOT NULL,\n')
          .join();
      String hourlyString = List.generate(24, (index) => index)
          .map((e) => 'Hour$e INTEGER NOT NULL,\n')
          .join();
      db.execute('''
CREATE TABLE CityForecast (
  Id INTEGER PRIMARY KEY,
  Temperature INTEGER NOT NULL,
  ProbOfPrecipitation INTEGER NOT NULL,
  Humidity INTEGER NOT NULL,
  WindSpeed INTEGER NOT NULL,
  WindDirection TEXT NOT NULL,
  $dailyString
  $hourlyString
  StartTime INTEGER NOT NULL,
  UpdateTime INTEGER NOT NULL
)
      ''');
    }, version: 3);
  }

  // ----- ----- CityInfo ----- -----

  Future<int> checkCityInfo(Points points, List<double> latLon) async {
    CityInfo? ci;
    WeatherException? we;
    (ci, we) = await getCityInfoPoints(points);
    if (ci != null) {
      return ci.id;
    } else {
      if (we == WeatherException.nonUniqueId) {
        return -1;
      }

      int cityId = await insertCityInfo(
        CityInfoCompanion(
          city: points.properties.relativeLocation.properties.city,
          state: points.properties.relativeLocation.properties.state,
          latitude: latLon[0],
          longitude: latLon[1],
          gridId: points.properties.gridId,
          gridX: points.properties.gridX,
          gridY: points.properties.gridY,
          time: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      return cityId;
    }
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

  Future<(CityInfo?, WeatherException?)> getCityInfoPoints(
      Points points) async {
    final List<Map<String, dynamic>> map = await db.query(
      'CityInfo',
      where: 'gridId = ? AND gridX = ? AND gridY = ?',
      whereArgs: [
        points.properties.gridId,
        points.properties.gridX,
        points.properties.gridY
      ],
    );
    switch (map.length) {
      case 0:
        return (null, WeatherException.cityInfoEmpty);
      case 1:
        return (CityInfo.fromMap(map[0]), null);
      default:
        return (null, WeatherException.nonUniqueId);
    }
  }

  Future<(CityInfo?, WeatherException?)> getCityInfoId(int cityId) async {
    final List<Map<String, dynamic>> map = await db.query(
      'CityInfo',
      where: 'Id = ?',
      whereArgs: [cityId],
    );
    switch (map.length) {
      case 0:
        return (null, WeatherException.cityInfoEmpty);
      case 1:
        return (CityInfo.fromMap(map[0]), null);
      default:
        return (null, WeatherException.nonUniqueId);
    }
  }

  // ----- ----- CityForecast ----- -----

  Future<int> insertCityForecast(CityForecast cityForecast) async {
    int result = await db.insert(
      'CityForecast',
      cityForecast.toCityForecastCompanion().toMap(),
    );
    return result;
  }

  Future<int> updateCityForecast(CityForecast cityForecast) async {
    int result = await db.update(
      'CityForecast',
      cityForecast.toCityForecastCompanion().toMap(),
      where: 'Id = ?',
      whereArgs: [cityForecast.id],
    );
    return result;
  }

  Future<(CityForecast?, WeatherException?)> getCityForecast(int id) async {
    final List<Map<String, dynamic>> map = await db.query(
      'CityForecast',
      where: 'Id = ?',
      whereArgs: [id],
    );
    switch (map.length) {
      case 0:
        return (null, WeatherException.cityForecastEmpty);
      case 1:
        return (CityForecastCompanion.fromMap(map[0]).toCityForecast(), null);

      default:
        return (null, WeatherException.nonUniqueId);
    }
  }

  Future<(CityForecast?, WeatherException?)> checkCityForecast(int id) async {
    WeatherException? et;
    CityForecast? cityForecast;
    (cityForecast, et) = await getCityForecast(id);
    if (cityForecast != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      // 900,000 ms = 15 min
      if (currentTime - cityForecast.updateTime > 900000) {
        CityForecast? newCityForecast;
        (newCityForecast, et) = await fetchAndInsertOrUpdate(
          id,
          true,
          cityForecast.startTime,
        );
        if (newCityForecast != null) {
          return (newCityForecast, null);
        } else {
          return (null, et);
        }
      } else {
        return (cityForecast, null);
      }
    } else {
      switch (et) {
        case WeatherException.cityForecastEmpty:
          CityForecast? newCityForecast;
          (newCityForecast, et) = await fetchAndInsertOrUpdate(id, false, null);
          if (newCityForecast != null) {
            return (newCityForecast, null);
          } else {
            return (null, et);
          }

        default:
          return (null, et);
      }
    }
  }

  // bool insertOrUpdate: false -> insert, true -> update
  Future<(CityForecast?, WeatherException?)> fetchAndInsertOrUpdate(
    id,
    bool insertOrUpdate,
    int? time,
  ) async {
    (ForecastInfo, ForecastInfo)? forecasts;
    WeatherException? et;
    (forecasts, et) = await fetchForecast(_databaseHelper, id);
    if (forecasts != null) {
      if (insertOrUpdate) {
        DateTime? dt =
            DateTime.tryParse(forecasts.$1.properties.periods[0].endTime);
        if (dt == null) {
          return (null, WeatherException.dateFormatError);
        }
        if (time! - dt.millisecondsSinceEpoch >= 86400000) {
          int _ = await updateCityForecast(
            toCityForecast(forecasts.$1, forecasts.$2, id),
          );
        } else {}
      } else {
        int _ = await insertCityForecast(
          toCityForecast(forecasts.$1, forecasts.$2, id),
        );
      }
      return (toCityForecast(forecasts.$1, forecasts.$2, id), null);
    } else {
      return (null, et);
    }
  }
}
