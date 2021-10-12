import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void commonSetUpAll() {
  registerFallbackValue(FakeTodo());
  registerFallbackValue(MockHomeState());
  registerFallbackValue(MockTodosOverviewState());
  registerFallbackValue(MockTodosOverviewEvent());
  registerFallbackValue(MockEditTodoState());
  registerFallbackValue(MockEditTodoEvent());
  registerFallbackValue(MockStatsState());
  registerFallbackValue(MockStatsEvent());
}
