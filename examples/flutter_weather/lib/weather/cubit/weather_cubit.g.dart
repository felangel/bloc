// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherLoadSuccess _$WeatherLoadSuccessFromJson(Map<String, dynamic> json) {
  return $checkedNew('WeatherLoadSuccess', json, () {
    final val = WeatherLoadSuccess(
      $checkedConvert(
          json,
          'weather',
          (v) =>
              v == null ? null : Weather.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

Map<String, dynamic> _$WeatherLoadSuccessToJson(WeatherLoadSuccess instance) =>
    <String, dynamic>{
      'weather': instance.weather?.toJson(),
    };
