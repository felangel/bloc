import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherCondition;

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    Key? key,
    required this.weather,
    required this.units,
    required this.onRefresh,
  }) : super(key: key);

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        _WeatherBackground(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  _WeatherIcon(condition: weather.condition),
                  Text(
                    weather.location,
                    style: theme.textTheme.headline2?.copyWith(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weather.formattedTemperature(units),
                    style: theme.textTheme.headline3?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}''',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({Key? key, required this.condition}) : super(key: key);

  static const _iconSize = 100.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
      default:
        return '❓';
    }
  }
}

class _WeatherBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.25, 0.75, 0.90, 1.0],
          colors: [
            color,
            color.brighten(10),
            color.brighten(33),
            color.brighten(50),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color brighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}''';
  }
}
