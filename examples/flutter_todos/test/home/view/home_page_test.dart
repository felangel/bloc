import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HomePage', () {
    setUpAll(commonSetUpAll);

    testWidgets(
      'renders TodosOverviewPage inside IndexedStack',
      (tester) async {
        await tester.pumpApp(
          const HomePage(),
        );

        expect(
          find.descendant(
            of: find.byType(IndexedStack),
            matching: find.byType(TodosOverviewPage),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
