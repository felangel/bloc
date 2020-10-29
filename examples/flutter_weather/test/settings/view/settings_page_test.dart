// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/settings/settings.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mockito/mockito.dart';

class MockWeatherCubit extends MockBloc<WeatherState> implements WeatherCubit {}

void main() {
  group('SettingsPage', () {
    WeatherCubit weatherCubit;

    setUp(() {
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('is routable', (tester) async {
      when(weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    SettingsPage.route(weatherCubit),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('calls toggleUnits when switch is changed', (tester) async {
      whenListen(
        weatherCubit,
        Stream.fromIterable([
          WeatherState(temperatureUnits: TemperatureUnits.celsius),
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ]),
      );
      when(weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    SettingsPage.route(weatherCubit),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      verify(weatherCubit.toggleUnits()).called(1);
    });
  });
}
