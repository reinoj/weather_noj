// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Points _$PointsFromJson(Map<String, dynamic> json) => Points(
      properties:
          PointsProperties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PointsToJson(Points instance) => <String, dynamic>{
      'properties': instance.properties,
    };

PointsProperties _$PointsPropertiesFromJson(Map<String, dynamic> json) =>
    PointsProperties(
      gridId: json['gridId'] as String,
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
      relativeLocation: RelativeLocation.fromJson(
          json['relativeLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PointsPropertiesToJson(PointsProperties instance) =>
    <String, dynamic>{
      'gridId': instance.gridId,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
      'relativeLocation': instance.relativeLocation,
    };

RelativeLocation _$RelativeLocationFromJson(Map<String, dynamic> json) =>
    RelativeLocation(
      properties:
          RLProperties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RelativeLocationToJson(RelativeLocation instance) =>
    <String, dynamic>{
      'properties': instance.properties,
    };

RLProperties _$RLPropertiesFromJson(Map<String, dynamic> json) => RLProperties(
      city: json['city'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$RLPropertiesToJson(RLProperties instance) =>
    <String, dynamic>{
      'city': instance.city,
      'state': instance.state,
    };
