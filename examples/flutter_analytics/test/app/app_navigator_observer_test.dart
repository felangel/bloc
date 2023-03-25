import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  group('AppNavigatorObserver', () {
    late AnalyticsRepository analyticsRepository;

    const screenView = ScreenView(routeName: 'routeName');

    setUp(() {
      analyticsRepository = MockAnalyticsRepository();
      when(
        () => analyticsRepository.send(screenView),
      ).thenAnswer(
        (_) => Future<void>.value(),
      );
    });

    test('can create an instance', () {
      expect(
        AppNavigatorObserver(analyticsRepository),
        isA<AppNavigatorObserver>(),
      );
    });

    test('sends analytics on push', () {
      AppNavigatorObserver(analyticsRepository).didPush(
        MaterialPageRoute(
          settings: const AnalyticRouteSettings(
            screenView: screenView,
          ),
          builder: (_) => Container(),
        ),
        null,
      );
      verify(() => analyticsRepository.send(screenView)).called(1);
    });

    test('sends no analytics for normal routes', () {
      AppNavigatorObserver(analyticsRepository).didPush(
        MaterialPageRoute(
          builder: (_) => Container(),
        ),
        null,
      );
      verifyNever(() => analyticsRepository.send(screenView));
    });

    test('sends analytics on pop', () {
      AppNavigatorObserver(analyticsRepository).didPop(
        MaterialPageRoute(
          builder: (_) => Container(),
        ),
        MaterialPageRoute(
          settings: const AnalyticRouteSettings(
            screenView: screenView,
          ),
          builder: (_) => Container(),
        ),
      );
      verify(() => analyticsRepository.send(screenView)).called(1);
    });

    test('sends analytics on replace', () {
      AppNavigatorObserver(analyticsRepository).didReplace(
        newRoute: MaterialPageRoute(
          settings: const AnalyticRouteSettings(
            screenView: screenView,
          ),
          builder: (_) => Container(),
        ),
      );
      verify(() => analyticsRepository.send(screenView)).called(1);
    });
  });
}
