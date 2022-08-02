// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) {
  return $checkedNew(
    'Weather',
    json,
    () {
      final val = Weather(
        id: $checkedConvert(json, 'id', (v) => v as int),
        weatherStateName:
            $checkedConvert(json, 'weather_state_name', (v) => v as String),
        weatherStateAbbr: $checkedConvert(
          json,
          'weather_state_abbr',
          (v) => _$enumDecode(
            _$WeatherStateEnumMap,
            v,
            unknownValue: WeatherState.unknown,
          ),
        ),
        windDirectionCompass: $checkedConvert(
          json,
          'wind_direction_compass',
          (v) => _$enumDecode(
            _$WindDirectionCompassEnumMap,
            v,
            unknownValue: WindDirectionCompass.unknown,
          ),
        ),
        created: $checkedConvert(
            json, 'created', (v) => DateTime.parse(v as String)),
        applicableDate: $checkedConvert(
          json,
          'applicable_date',
          (v) => DateTime.parse(v as String),
        ),
        minTemp:
            $checkedConvert(json, 'min_temp', (v) => (v as num).toDouble()),
        maxTemp:
            $checkedConvert(json, 'max_temp', (v) => (v as num).toDouble()),
        theTemp:
            $checkedConvert(json, 'the_temp', (v) => (v as num).toDouble()),
        windSpeed:
            $checkedConvert(json, 'wind_speed', (v) => (v as num).toDouble()),
        windDirection: $checkedConvert(
            json, 'wind_direction', (v) => (v as num).toDouble()),
        airPressure:
            $checkedConvert(json, 'air_pressure', (v) => (v as num).toDouble()),
        humidity: $checkedConvert(json, 'humidity', (v) => v as int),
        visibility:
            $checkedConvert(json, 'visibility', (v) => (v as num).toDouble()),
        predictability:
            $checkedConvert(json, 'predictability', (v) => v as int),
      );
      return val;
    },
    fieldKeyMap: const {
      'weatherStateName': 'weather_state_name',
      'weatherStateAbbr': 'weather_state_abbr',
      'windDirectionCompass': 'wind_direction_compass',
      'applicableDate': 'applicable_date',
      'minTemp': 'min_temp',
      'maxTemp': 'max_temp',
      'theTemp': 'the_temp',
      'windSpeed': 'wind_speed',
      'windDirection': 'wind_direction',
      'airPressure': 'air_pressure'
    },
  );
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$WeatherStateEnumMap = {
  WeatherState.snow: 'sn',
  WeatherState.sleet: 'sl',
  WeatherState.hail: 'h',
  WeatherState.thunderstorm: 't',
  WeatherState.heavyRain: 'hr',
  WeatherState.lightRain: 'lr',
  WeatherState.showers: 's',
  WeatherState.heavyCloud: 'hc',
  WeatherState.lightCloud: 'lc',
  WeatherState.clear: 'c',
  WeatherState.unknown: 'unknown',
};

const _$WindDirectionCompassEnumMap = {
  WindDirectionCompass.north: 'N',
  WindDirectionCompass.northEast: 'NE',
  WindDirectionCompass.east: 'E',
  WindDirectionCompass.southEast: 'SE',
  WindDirectionCompass.south: 'S',
  WindDirectionCompass.southWest: 'SW',
  WindDirectionCompass.west: 'W',
  WindDirectionCompass.northWest: 'NW',
  WindDirectionCompass.unknown: 'unknown',
};
