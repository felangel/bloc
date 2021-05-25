import 'package:flutter/material.dart';
import 'package:flutter_complex_list/app.dart';
import 'package:flutter_complex_list/complex_list/complex_list.dart';
import 'package:flutter_complex_list/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late Repository repository;

  setUp(() {
    repository = MockRepository();
  });

  group('App', () {
    testWidgets('is a MaterialApp', (tester) async {
      expect(App(repository: repository), isA<MaterialApp>());
    });

    testWidgets('renders ComplexListPage', (tester) async {
      when(repository.fetchItems).thenAnswer((_) async => []);
      await tester.pumpWidget(App(repository: repository));
      expect(find.byType(ComplexListPage), findsOneWidget);
    });
  });
}
