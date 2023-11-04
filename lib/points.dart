import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'points.g.dart';

Future<Points> fetchPoints(double lat, double lon) async {
  final response =
      await http.get(Uri.parse('https://api.weather.gov/points/$lat,$lon'));
  if (response.statusCode == 200) {
    return Points.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to get Points');
  }
}

@JsonSerializable()
class Points {
  final PointsProperties properties;

  Points({
    required this.properties,
  });

  factory Points.fromJson(Map<String, dynamic> json) => _$PointsFromJson(json);

  Map<String, dynamic> toJson() => _$PointsToJson(this);

  @override
  String toString() {
    return '${properties.gridId}: ${properties.gridX}, ${properties.gridY}';
  }
}

@JsonSerializable()
class PointsProperties {
  final String gridId;
  final int gridX, gridY;
  final RelativeLocation relativeLocation;

  PointsProperties({
    required this.gridId,
    required this.gridX,
    required this.gridY,
    required this.relativeLocation,
  });

  factory PointsProperties.fromJson(Map<String, dynamic> json) =>
      _$PointsPropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$PointsPropertiesToJson(this);
}

@JsonSerializable()
class RelativeLocation {
  final RLProperties properties;

  RelativeLocation({
    required this.properties,
  });

  factory RelativeLocation.fromJson(Map<String, dynamic> json) =>
      _$RelativeLocationFromJson(json);

  Map<String, dynamic> toJson() => _$RelativeLocationToJson(this);
}

@JsonSerializable()
class RLProperties {
  final String city;
  final String state;

  RLProperties({
    required this.city,
    required this.state,
  });

  factory RLProperties.fromJson(Map<String, dynamic> json) =>
      _$RLPropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$RLPropertiesToJson(this);
}
