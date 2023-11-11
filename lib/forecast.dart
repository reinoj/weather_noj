import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_noj/city.dart';
import 'package:weather_noj/database.dart';

part 'forecast.g.dart';

Future<(ForecastInfo?, ExceptionType?)> fetchForecast(
    DatabaseHelper databaseHelper, int id) async {
  CityInfo? cityInfo;
  ExceptionType? et;
  (cityInfo, et) = await databaseHelper.getCityInfo(id);
  if (cityInfo != null) {
    final response = await http.get(
      Uri.parse(
        'https://api.weather.gov/gridpoints/${cityInfo.gridId}/${cityInfo.gridX},${cityInfo.gridY}/forecast',
      ),
    );
    if (response.statusCode == 200) {
      return (
        ForecastInfo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        ),
        null
      );
    } else {
      // could change this to returning some type of error
      return (null, ExceptionType.non200Response);
    }
  } else {
    return (null, et);
  }
}

@JsonSerializable()
class ForecastInfo {
  final ForecastProperties properties;

  ForecastInfo({
    required this.properties,
  });

  factory ForecastInfo.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);
}

@JsonSerializable()
class ForecastProperties {
  final String updated;
  final List<ForecastPeriod> periods;

  ForecastProperties({
    required this.updated,
    required this.periods,
  });

  factory ForecastProperties.fromJson(Map<String, dynamic> json) =>
      _$ForecastPropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastPropertiesToJson(this);
}

@JsonSerializable()
class ForecastPeriod {
  final String
      endTime; // subtract 12 hours from time, so the evening time will be the same day as morning
  final int temperature;
  final UnitValue probabilityofPrecipitation;
  final UnitValue relativeHumidity;
  final String windSpeed;
  final String windDirection;

  ForecastPeriod({
    required this.endTime,
    required this.temperature,
    required this.probabilityofPrecipitation,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
  });

  factory ForecastPeriod.fromJson(Map<String, dynamic> json) =>
      _$ForecastPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastPeriodToJson(this);
}

@JsonSerializable()
class UnitValue {
  final int? value;

  UnitValue({
    required this.value,
  });

  factory UnitValue.fromJson(Map<String, dynamic> json) =>
      _$UnitValueFromJson(json);

  Map<String, dynamic> toJson() => _$UnitValueToJson(this);
}
