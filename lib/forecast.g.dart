// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastInfo _$ForecastInfoFromJson(Map<String, dynamic> json) => ForecastInfo(
      properties: ForecastProperties.fromJson(
          json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastInfoToJson(ForecastInfo instance) =>
    <String, dynamic>{
      'properties': instance.properties,
    };

ForecastProperties _$ForecastPropertiesFromJson(Map<String, dynamic> json) =>
    ForecastProperties(
      updated: json['updated'] as String,
      periods: (json['periods'] as List<dynamic>)
          .map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForecastPropertiesToJson(ForecastProperties instance) =>
    <String, dynamic>{
      'updated': instance.updated,
      'periods': instance.periods,
    };

ForecastPeriod _$ForecastPeriodFromJson(Map<String, dynamic> json) =>
    ForecastPeriod(
      endTime: json['endTime'] as String,
      temperature: json['temperature'] as int,
      probabilityOfPrecipitation: UnitValue.fromJson(
          json['probabilityOfPrecipitation'] as Map<String, dynamic>),
      relativeHumidity:
          UnitValue.fromJson(json['relativeHumidity'] as Map<String, dynamic>),
      windSpeed: json['windSpeed'] as String,
      windDirection: json['windDirection'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$ForecastPeriodToJson(ForecastPeriod instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'temperature': instance.temperature,
      'probabilityOfPrecipitation': instance.probabilityOfPrecipitation,
      'relativeHumidity': instance.relativeHumidity,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
      'icon': instance.icon,
    };

UnitValue _$UnitValueFromJson(Map<String, dynamic> json) => UnitValue(
      value: json['value'] as int?,
    );

Map<String, dynamic> _$UnitValueToJson(UnitValue instance) => <String, dynamic>{
      'value': instance.value,
    };
