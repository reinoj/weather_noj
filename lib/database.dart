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

/*
check city forecast should take in and id, and check the times to see what needs to be udpated.
then have 2 update functions for hourly and daily, for updating the relevant rows
*/
  Future<int> updateCityForecast(CityForecast cityForecast) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    int timeSinceUpdate = now - cityForecast.updateTime;
    if (timeSinceUpdate > 900000) {
      (CityInfo?, WeatherException?) cityInfo =
          await getCityInfoId(cityForecast.id);
      if (cityInfo.$1 == null) {
        return -1;
      }
      // check hourly
      await fetchForecastDaily(cityInfo.$1!);

      DateTime updateTime =
          DateTime.fromMillisecondsSinceEpoch(cityForecast.updateTime);
      DateTime updateThreshold;
      switch (updateTime.hour) {
        case < 5:
          updateThreshold = DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.day,
            6,
          );
          break;
        case < 18:
          updateThreshold = DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.day,
            18,
          );
          break;
        default:
          updateThreshold = DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.day,
            6,
          );
          updateThreshold.add(Duration(days: 1));
          break;
      }
      if (now - updateThreshold.millisecondsSinceEpoch >= 0) {
        // check daily
      }
    }

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
        CityForecast cf =
            CityForecastCompanion.fromMap(map[0]).toCityForecast();
        return (cf, null);

      default:
        return (null, WeatherException.nonUniqueId);
    }
  }

  Future<void> checkDaily(CityForecast cityForecast) async {
    (CityInfo?, WeatherException?) cityInfo =
        await getCityInfoId(cityForecast.id);
    if (cityInfo.$1 != null) {
      (ForecastInfo?, WeatherException?) dailyForecast =
          await fetchForecastDaily(cityInfo.$1!);
      if (dailyForecast.$1 != null) {
        updateDaily(cityForecast.id, dailyForecast.$1!.toDailyForecast());
      }
    }
  }

  Future<void> updateDaily(int id, List<int> dailyForecast) async {
    int _ = await db.rawUpdate('''
UPDATE CityForecast
SET day0_0 = ?, day0_1 = ?, day1_0 = ?, day1_1 = ?, day2_0 = ?, day2_1 = ?, day3_0 = ?, day3_1 = ?, day4_0 = ?, day4_1 = ?, day5_0 = ?, day5_1 = ?, day6_0 = ?, day6_1 = ?
WHERE Id = ?
''', [...dailyForecast, id]);
  }
}
