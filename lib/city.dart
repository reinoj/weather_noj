class CityInfo {
  final int id;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String gridId;
  final int gridX;
  final int gridY;
  final int time;

  CityInfo({
    required this.id,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.gridId,
    required this.gridX,
    required this.gridY,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'CityName': city,
      'StateName': state,
      'Latitude': latitude,
      'Longitude': longitude,
      'GridId': gridId,
      'GridX': gridX,
      'GridY': gridY,
      'Time': time,
    };
  }

  CityInfo.fromMap(Map<String, dynamic> res)
      : id = res['Id'],
        city = res['City'],
        state = res['State'],
        latitude = res['Latitude'],
        longitude = res['Longitude'],
        gridId = res['GridId'],
        gridX = res['GridX'],
        gridY = res['GridY'],
        time = res['Time'];

  @override
  String toString() {
    return '$city, $state:\n$gridId - $gridX, $gridY\n$latitude, $longitude\ntime: $time';
  }
}

class CityInfoCompanion {
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String gridId;
  final int gridX;
  final int gridY;
  final int time;

  CityInfoCompanion(
      {required this.city,
      required this.state,
      required this.latitude,
      required this.longitude,
      required this.gridId,
      required this.gridX,
      required this.gridY,
      required this.time});

  Map<String, dynamic> toMap() {
    return {
      'City': city,
      'State': state,
      'Latitude': latitude,
      'Longitude': longitude,
      'GridId': gridId,
      'GridX': gridX,
      'GridY': gridY,
      'Time': time,
    };
  }

  CityInfoCompanion.fromMap(Map<String, dynamic> res)
      : city = res['City'],
        state = res['State'],
        latitude = res['Latitude'],
        longitude = res['Longitude'],
        gridId = res['GridId'],
        gridX = res['GridX'],
        gridY = res['GridY'],
        time = res['Time'];
}

// ----- ----- ----- -----

class CityForecast {
  final int id;
  final int temperature;
  final int probOfPrecipitation;
  final int humidity;
  final String windSpeed;
  final String windDirection;
  final List<int> dailyForecast;
  final List<int> hourlyForecast;
  final int endTime;
  final int updateTime;

  CityForecast({
    required this.id,
    required this.temperature,
    required this.probOfPrecipitation,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.dailyForecast,
    required this.hourlyForecast,
    required this.endTime,
    required this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Temperature': temperature,
      'ProbOfPrecipitation': probOfPrecipitation,
      'Humidity': humidity,
      'WindSpeed': windSpeed,
      'WindDirection': windDirection,
      'DailyForecast': dailyForecast,
      'HourlyForecast': hourlyForecast,
      'EndTime': endTime,
      'UpdateTime': updateTime,
    };
  }

  CityForecast.fromMap(Map<String, dynamic> res)
      : id = res['Id'],
        temperature = res['Temperature'],
        probOfPrecipitation = res['ProbOfPrecipitation'],
        humidity = res['Humidity'],
        windSpeed = res['WindSpeed'],
        windDirection = res['WindDirection'],
        dailyForecast = res['DailyForecast'],
        hourlyForecast = res['HourlyForecast'],
        endTime = res['EndTime'],
        updateTime = res['UpdateTime'];
}

/*
for i in range(0, 14):
  print(f'final int day{i//2}_{i%2};')
  print(f'required this.day{i//2}_{i%2},')
  print(f'\'Day{i//2}_{i%2}\': day{i//2}_{i%2},')
  print(f'day{i//2}_{i%2} = res[\'Day{i//2}_{i%2}\'],')

for i in range(0, 24):
  print(f'final int hour{i};')
  print(f'required this.hour{i},')
  print(f'\'Hour{i}\': hour{i},')
  print(f'hour{i} = res[\'Hour{i}\'],')

toCityForecast()
for i in range(0, 7):
  print(f'[day{i}_0, day{i}_1],')
for i in range(0, 24):
  print(f'hour{i},')
*/
class CityForecastCompanion {
  final int id;
  final int temperature;
  final int probOfPrecipitation;
  final int humidity;
  final String windSpeed;
  final String windDirection;
  final int day0_0;
  final int day0_1;
  final int day1_0;
  final int day1_1;
  final int day2_0;
  final int day2_1;
  final int day3_0;
  final int day3_1;
  final int day4_0;
  final int day4_1;
  final int day5_0;
  final int day5_1;
  final int day6_0;
  final int day6_1;
  final int hour0;
  final int hour1;
  final int hour2;
  final int hour3;
  final int hour4;
  final int hour5;
  final int hour6;
  final int hour7;
  final int hour8;
  final int hour9;
  final int hour10;
  final int hour11;
  final int hour12;
  final int hour13;
  final int hour14;
  final int hour15;
  final int hour16;
  final int hour17;
  final int hour18;
  final int hour19;
  final int hour20;
  final int hour21;
  final int hour22;
  final int hour23;
  final int endTime;
  final int updateTime;

  CityForecast toCityForecast() {
    List<int> daily = [
      day0_0,
      day0_1,
      day1_0,
      day1_1,
      day2_0,
      day2_1,
      day3_0,
      day3_1,
      day4_0,
      day4_1,
      day5_0,
      day5_1,
      day6_0,
      day6_1,
    ];
    List<int> hourly = [
      hour0,
      hour1,
      hour2,
      hour3,
      hour4,
      hour5,
      hour6,
      hour7,
      hour8,
      hour9,
      hour10,
      hour11,
      hour12,
      hour13,
      hour14,
      hour15,
      hour16,
      hour17,
      hour18,
      hour19,
      hour20,
      hour21,
      hour22,
      hour23,
    ];
    return CityForecast(
      id: id,
      temperature: temperature,
      probOfPrecipitation: probOfPrecipitation,
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: windDirection,
      dailyForecast: daily,
      hourlyForecast: hourly,
      endTime: endTime,
      updateTime: updateTime,
    );
  }

  CityForecastCompanion({
    required this.id,
    required this.temperature,
    required this.probOfPrecipitation,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.day0_0,
    required this.day0_1,
    required this.day1_0,
    required this.day1_1,
    required this.day2_0,
    required this.day2_1,
    required this.day3_0,
    required this.day3_1,
    required this.day4_0,
    required this.day4_1,
    required this.day5_0,
    required this.day5_1,
    required this.day6_0,
    required this.day6_1,
    required this.hour0,
    required this.hour1,
    required this.hour2,
    required this.hour3,
    required this.hour4,
    required this.hour5,
    required this.hour6,
    required this.hour7,
    required this.hour8,
    required this.hour9,
    required this.hour10,
    required this.hour11,
    required this.hour12,
    required this.hour13,
    required this.hour14,
    required this.hour15,
    required this.hour16,
    required this.hour17,
    required this.hour18,
    required this.hour19,
    required this.hour20,
    required this.hour21,
    required this.hour22,
    required this.hour23,
    required this.endTime,
    required this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Temperature': temperature,
      'ProbOfPrecipitation': probOfPrecipitation,
      'Humidity': humidity,
      'WindSpeed': windSpeed,
      'WindDirection': windDirection,
      'Day0_0': day0_0,
      'Day0_1': day0_1,
      'Day1_0': day1_0,
      'Day1_1': day1_1,
      'Day2_0': day2_0,
      'Day2_1': day2_1,
      'Day3_0': day3_0,
      'Day3_1': day3_1,
      'Day4_0': day4_0,
      'Day4_1': day4_1,
      'Day5_0': day5_0,
      'Day5_1': day5_1,
      'Day6_0': day6_0,
      'Day6_1': day6_1,
      'Hour0': hour0,
      'Hour1': hour1,
      'Hour2': hour2,
      'Hour3': hour3,
      'Hour4': hour4,
      'Hour5': hour5,
      'Hour6': hour6,
      'Hour7': hour7,
      'Hour8': hour8,
      'Hour9': hour9,
      'Hour10': hour10,
      'Hour11': hour11,
      'Hour12': hour12,
      'Hour13': hour13,
      'Hour14': hour14,
      'Hour15': hour15,
      'Hour16': hour16,
      'Hour17': hour17,
      'Hour18': hour18,
      'Hour19': hour19,
      'Hour20': hour20,
      'Hour21': hour21,
      'Hour22': hour22,
      'Hour23': hour23,
      'EndTime': endTime,
      'UpdateTime': updateTime,
    };
  }

  CityForecastCompanion.fromMap(Map<String, dynamic> res)
      : id = res['Id'],
        temperature = res['Temperature'],
        probOfPrecipitation = res['ProbOfPrecipitation'],
        humidity = res['Humidity'],
        windSpeed = res['WindSpeed'],
        windDirection = res['WindDirection'],
        day0_0 = res['Day0_0'],
        day0_1 = res['Day0_1'],
        day1_0 = res['Day1_0'],
        day1_1 = res['Day1_1'],
        day2_0 = res['Day2_0'],
        day2_1 = res['Day2_1'],
        day3_0 = res['Day3_0'],
        day3_1 = res['Day3_1'],
        day4_0 = res['Day4_0'],
        day4_1 = res['Day4_1'],
        day5_0 = res['Day5_0'],
        day5_1 = res['Day5_1'],
        day6_0 = res['Day6_0'],
        day6_1 = res['Day6_1'],
        hour0 = res['Hour0'],
        hour1 = res['Hour1'],
        hour2 = res['Hour2'],
        hour3 = res['Hour3'],
        hour4 = res['Hour4'],
        hour5 = res['Hour5'],
        hour6 = res['Hour6'],
        hour7 = res['Hour7'],
        hour8 = res['Hour8'],
        hour9 = res['Hour9'],
        hour10 = res['Hour10'],
        hour11 = res['Hour11'],
        hour12 = res['Hour12'],
        hour13 = res['Hour13'],
        hour14 = res['Hour14'],
        hour15 = res['Hour15'],
        hour16 = res['Hour16'],
        hour17 = res['Hour17'],
        hour18 = res['Hour18'],
        hour19 = res['Hour19'],
        hour20 = res['Hour20'],
        hour21 = res['Hour21'],
        hour22 = res['Hour22'],
        hour23 = res['Hour23'],
        endTime = res['EndTime'],
        updateTime = res['UpdateTime'];
}
