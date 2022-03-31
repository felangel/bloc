import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

FutureOr<T> mockHydratedStorage<T>(
  FutureOr<T> Function() body, {
  Storage? storage,
}) {
  return HydratedBlocOverrides.runZoned<T>(
    body,
    createStorage: () => storage ?? _buildMockStorage(),
  );
}

Storage _buildMockStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = MockStorage();
  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  return storage;
}
