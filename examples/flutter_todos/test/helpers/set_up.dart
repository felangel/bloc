import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void commonSetUpAll() {
  registerFallbackValue(FakeTodo());
}
