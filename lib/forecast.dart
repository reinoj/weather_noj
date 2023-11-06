import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'forecast.g.dart';

// Future<Forecast> fetchForecast(int id) async {
//   final response = await http.get(Uri.parse(
//       'https://api.weather.gov/gridpoints/$gridId/$gridX,$gridY/forecast'));
//   if (response.statusCode == 200) {
//     return Forecast.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
//   } else {
//     throw Exception('Failed to get Forecast');
//   }
// }

@JsonSerializable()
class Forecast {
  final ForecastProperties properties;

  Forecast({
    required this.properties,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) =>
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
