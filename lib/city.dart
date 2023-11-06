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
  // final int current;
  // final List<List<int>> forecast;
  // final List<int> hourly;
  // final int infoTime;
  // final int weatherTime;

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

class CityForecast {
  final int id;
  final int temperature;
  final int probOfPrecipitation;
  final int humidity;
  final int windSpeed;
  final String windDirection;
  final String dailyForecast;
  final String hourlyForecast;
  final int endTime;
  final int updateTime;
  final int checkedTime;

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
    required this.checkedTime,
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
      'CheckedTime': checkedTime,
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
        updateTime = res['UpdateTime'],
        checkedTime = res['CheckedTime'];
}
