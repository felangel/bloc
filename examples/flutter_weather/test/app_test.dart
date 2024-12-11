import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/app.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

import 'helpers/hydrated_bloc.dart';

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  initHydratedStorage();

  group('WeatherApp', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherAppView', (tester) async {
      await tester.pumpWidget(
        WeatherApp(weatherRepository: weatherRepository),
      );
      expect(find.byType(WeatherAppView), findsOneWidget);
    });
  });

  group('WeatherAppView', () {
    late WeatherCubit weatherCubit;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherCubit = MockWeatherCubit();
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherPage', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: BlocProvider.value(
            value: weatherCubit,
            child: const WeatherAppView(),
          ),
        ),
      );
      expect(find.byType(WeatherPage), findsOneWidget);
    });

    testWidgets('has correct theme color scheme', (tester) async {
      final state = WeatherState(
        status: WeatherStatus.success,
        weather: Weather(
          condition: WeatherCondition.rainy,
          lastUpdated: DateTime(2024),
          location: 'Seattle',
          temperature: const Temperature(value: 20),
        ),
      );
      when(() => weatherCubit.state).thenReturn(state);
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: BlocProvider.value(
            value: weatherCubit,
            child: const WeatherAppView(),
          ),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.theme?.colorScheme,
        ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
      );
    });
  });
}
