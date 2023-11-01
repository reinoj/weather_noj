import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'points.g.dart';

@JsonSerializable()
class Points {
  final Properties properties;

  Points({required this.properties});

  factory Points.fromJson(Map<String, dynamic> json) => _$PointsFromJson(json);
  Map<String, dynamic> toJson() => _$PointsToJson(this);
}

@JsonSerializable()
class Properties {
  final String gridId;
  final int gridX, gridY;

  Properties({required this.gridId, required this.gridX, required this.gridY});
  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}

Future<Points> fetchPoints() async {
  final response =
      await http.get(Uri.parse("https://api.weather.gov/points/44.99,-93.25"));
  if (response.statusCode == 200) {
    return Points.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception("Failed to get Points");
  }
}
