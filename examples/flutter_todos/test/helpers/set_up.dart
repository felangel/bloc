import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void commonSetUpAll() {
  registerFallbackValue(FakeTodo());
  registerFallbackValue(MockHomeState());
  registerFallbackValue(MockTodosOverviewState());
  registerFallbackValue(MockTodosOverviewEvent());
  registerFallbackValue(MockStatsState());
  registerFallbackValue(MockStatsEvent());
}
