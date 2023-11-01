// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Points _$PointsFromJson(Map<String, dynamic> json) => Points(
      properties:
          Properties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PointsToJson(Points instance) => <String, dynamic>{
      'properties': instance.properties,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
      gridId: json['gridId'] as String,
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'gridId': instance.gridId,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
    };
