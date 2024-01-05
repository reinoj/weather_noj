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
  Icon INTEGER,
  $dailyString
  $hourlyString
  StartTime INTEGER NOT NULL,
  UpdateTime INTEGER NOT NULL
)
      ''');
    }, version: 4);
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

  int getUpdateThreshold(DateTime updateTime) {
    DateTime updateThreshold;
    switch (updateTime.hour) {
      case < 5:
        // 0-5
        updateThreshold = DateTime(
          updateTime.year,
          updateTime.month,
          updateTime.day,
          6,
        );
        break;
      case < 18:
        // 6-17
        updateThreshold = DateTime(
          updateTime.year,
          updateTime.month,
          updateTime.day,
          18,
        );
        break;
      default:
        // 18-23
        updateThreshold = DateTime(
          updateTime.year,
          updateTime.month,
          updateTime.day,
          6,
        );
        updateThreshold.add(Duration(days: 1));
        break;
    }
    return updateThreshold.millisecondsSinceEpoch;
  }

  Future<void> checkForecast(int id) async {
    (CityForecast?, WeatherException?) cityForecast = await getCityForecast(id);
    if (cityForecast.$1 == null) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    int timeSinceUpdate = now - cityForecast.$1!.updateTime;

    print(DateTime.fromMillisecondsSinceEpoch(cityForecast.$1!.updateTime));

    if (timeSinceUpdate > 900000) {
      (CityInfo?, WeatherException?) cityInfo =
          await getCityInfoId(cityForecast.$1!.id);
      if (cityInfo.$1 == null) {
        print('checkForecat: cityInfo is null.');

        return;
      }
      // check hourly
      await checkHourly(cityInfo.$1!);

      DateTime updateTime =
          DateTime.fromMillisecondsSinceEpoch(cityForecast.$1!.updateTime);
      int updateThreshold = getUpdateThreshold(updateTime);
      if (now - updateThreshold >= 0) {
        await checkDaily(cityInfo.$1!);
      } else {
        print('Too soon for daily update.');
      }
    } else {
      print('Too soon for hourly update.');
    }
  }

  Future<void> checkDaily(CityInfo cityInfo) async {
    (ForecastInfo?, WeatherException?) dailyForecast =
        await fetchForecastDaily(cityInfo);
    if (dailyForecast.$1 != null) {
      updateDaily(cityInfo.id, dailyForecast.$1!.toDailyForecast());
    }
  }

  Future<void> updateDaily(int id, List<int> dailyForecast) async {
    int _ = await db.rawUpdate('''
UPDATE CityForecast
SET Day0_0 = ?, Day0_1 = ?, Day1_0 = ?, Day1_1 = ?, Day2_0 = ?, Day2_1 = ?, Day3_0 = ?, Day3_1 = ?, Day4_0 = ?, Day4_1 = ?, Day5_0 = ?, Day5_1 = ?, Day6_0 = ?, Day6_1 = ?
WHERE Id = ?
''', [...dailyForecast, id]);
  }

  Future<void> checkHourly(CityInfo cityInfo) async {
    (ForecastInfo?, WeatherException?) hourlyForecast =
        await fetchForecastHourly(cityInfo);
    if (hourlyForecast.$1 != null) {
      await updateHourly(cityInfo.id, hourlyForecast.$1!);
    } else {
      print('hourlyForecast is null');
    }
  }

  /*
  s = ''
  for i in range(0,24):
    s += f'Hour{i} = ?, '
  */
  Future<void> updateHourly(int id, ForecastInfo forecastInfo) async {
    int pop = forecastInfo
                .properties.periods[0].probabilityOfPrecipitation.value !=
            null
        ? forecastInfo.properties.periods[0].probabilityOfPrecipitation.value!
        : 0;
    int humidity =
        forecastInfo.properties.periods[0].relativeHumidity.value != null
            ? forecastInfo.properties.periods[0].relativeHumidity.value!
            : 0;
    int result = await db.rawUpdate('''
UPDATE CityForecast
SET Temperature = ?, ProbOfPrecipitation = ?, Humidity = ?, WindSpeed = ?, WindDirection = ?, Hour0 = ?, Hour1 = ?, Hour2 = ?, Hour3 = ?, Hour4 = ?, Hour5 = ?, Hour6 = ?, Hour7 = ?, Hour8 = ?, Hour9 = ?, Hour10 = ?, Hour11 = ?, Hour12 = ?, Hour13 = ?, Hour14 = ?, Hour15 = ?, Hour16 = ?, Hour17 = ?, Hour18 = ?, Hour19 = ?, Hour20 = ?, Hour21 = ?, Hour22 = ?, Hour23 = ?, StartTime = ?, UpdateTime = ?
WHERE Id = ?
''', [
      forecastInfo.properties.periods[0].temperature,
      pop,
      humidity,
      forecastInfo.properties.periods[0].windSpeed,
      forecastInfo.properties.periods[0].windDirection,
      ...forecastInfo.toHourlyForecast(),
      DateTime.parse(forecastInfo.properties.periods[0].endTime)
              .millisecondsSinceEpoch -
          3600000,
      DateTime.parse(forecastInfo.properties.updated).millisecondsSinceEpoch,
      id,
    ]);
    print('updateHourly result: $result');
  }
}

/*



*/