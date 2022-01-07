import 'package:flutter/material.dart';
import 'package:flutter_counter/app.dart';
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('CounterApp', () {
    testWidgets('is a MaterialApp', (tester) async {
      expect(mockHydratedStorage(() => const CounterApp()), isA<MaterialApp>());
    });

    testWidgets('home is CounterPage', (tester) async {
      expect(mockHydratedStorage(() => const CounterApp()).home,
          isA<CounterPage>());
    });

    testWidgets('renders CounterPage', (tester) async {
      await mockHydratedStorage(() => tester.pumpWidget(const CounterApp()));
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}

class MockStorage extends Mock implements Storage {}

T mockHydratedStorage<T>(T Function() body, {Storage? storage}) {
  return HydratedBlocOverrides.runZoned<T>(
    body,
    storage: storage ?? _buildMockStorage(),
  );
}

Storage _buildMockStorage() {
  final storage = MockStorage();
  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  return storage;
}
