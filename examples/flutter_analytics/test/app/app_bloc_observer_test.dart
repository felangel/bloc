import 'package:analytics_repository/analytics_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockBloc extends Mock implements Bloc<dynamic, dynamic> {}

class AnalyticEvent extends Equatable with Analytic {
  @override
  String get eventName => 'testAnalytic';

  @override
  List<Object> get props => [];
}

void main() {
  group('AppBlocObserver', () {
    late AnalyticsRepository analyticsRepository;
    late Bloc<dynamic, dynamic> bloc;

    setUp(() {
      analyticsRepository = MockAnalyticsRepository();
      when(() => analyticsRepository.send(AnalyticEvent())).thenAnswer(
        (_) => Future<void>.value(),
      );
      bloc = MockBloc();
    });

    test('can create an instance', () {
      expect(
        AppBlocObserver(analyticsRepository),
        isA<AppBlocObserver>(),
      );
    });

    test('sends analytics', () {
      AppBlocObserver(analyticsRepository).onEvent(
        bloc,
        AnalyticEvent(),
      );
      verify(() => analyticsRepository.send(AnalyticEvent())).called(1);
    });
  });
}
