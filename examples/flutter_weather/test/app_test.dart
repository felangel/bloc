import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/app.dart';
import 'package:flutter_weather/theme/theme.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

import 'helpers/hydrated_bloc.dart';

class FakeColor extends Fake implements Color {}

class MockThemeCubit extends MockCubit<Color> implements ThemeCubit {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  setUpAll(() {
    initHydratedBloc();
    registerFallbackValue<Color>(FakeColor());
  });

  group('WeatherApp', () {
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherAppView', (tester) async {
      await tester.pumpWidget(WeatherApp(weatherRepository: weatherRepository));
      expect(find.byType(WeatherAppView), findsOneWidget);
    });
  });

  group('WeatherAppView', () {
    late ThemeCubit themeCubit;
    late WeatherRepository weatherRepository;

    setUp(() {
      themeCubit = MockThemeCubit();
      weatherRepository = MockWeatherRepository();
    });

    testWidgets('renders WeatherPage', (tester) async {
      when(() => themeCubit.state).thenReturn(Colors.blue);
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
      when(() => themeCubit.state).thenReturn(color);
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: weatherRepository,
          child: BlocProvider.value(value: themeCubit, child: WeatherAppView()),
        ),
      );
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.primaryColor, color);
    });
  });
}
