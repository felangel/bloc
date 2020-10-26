import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/app.dart';
import 'package:flutter_weather/theme/theme.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

class MockThemeCubit extends MockBloc<Color> implements ThemeCubit {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  initHydratedBloc();
  group('WeatherApp', () {
    WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    test('requires a WeatherRepository', () async {
      expect(() => WeatherApp(weatherRepository: null), throwsAssertionError);
    });

    testWidgets('renders WeatherAppView', (tester) async {
      await tester.pumpWidget(WeatherApp(weatherRepository: weatherRepository));
      expect(find.byType(WeatherAppView), findsOneWidget);
    });
  });

  group('WeatherAppView', () {
    ThemeCubit themeCubit;
    WeatherRepository weatherRepository;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherPage', (tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: BlocProvider.value(value: themeCubit, child: WeatherAppView()),
        ),
      );
      expect(find.byType(WeatherPage), findsOneWidget);
    });

    testWidgets('has correct theme primary color', (tester) async {
      const color = Color(0xFFD2D2D2);
      when(themeCubit.state).thenReturn(color);
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: BlocProvider.value(value: themeCubit, child: WeatherAppView()),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme.primaryColor, color);
    });
  });
}
