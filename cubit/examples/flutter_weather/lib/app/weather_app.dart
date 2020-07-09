import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_weather/app/weather/weather_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_weather/app/app.dart';
import 'package:flutter_weather/service/service.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key key, @required this.weatherService}) : super(key: key);

  final WeatherService weatherService;

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  Color _primaryColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      theme: ThemeData(
        primaryColor: _primaryColor,
        textTheme: GoogleFonts.rajdhaniTextTheme(textTheme),
        appBarTheme: AppBarTheme(
          textTheme: GoogleFonts.rajdhaniTextTheme(textTheme).apply(
            bodyColor: Colors.white,
          ),
        ),
      ),
      home: CubitProvider(
        create: (_) => WeatherCubit(widget.weatherService),
        child: const WeatherPage(),
      ),
    );
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orangeAccent;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
      default:
        return null;
    }
  }
}
