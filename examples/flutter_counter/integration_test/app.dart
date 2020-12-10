import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_counter/main.dart' as app;

const _incrementButtonKey = Key('counterView_increment_floatingActionButton');
const _decrementButtonKey = Key('counterView_decrement_floatingActionButton');

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verify the App Bar text', (WidgetTester tester) async {
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Verify AppBar text
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data.startsWith('Counter'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('counterText is started with 0', (WidgetTester tester) async {
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Verify AppBar text
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data.startsWith('0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tap the increment floating action button',
      (WidgetTester tester) async {
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_incrementButtonKey));

    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byKey(_incrementButtonKey));

    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tap the decrement floating action button',
      (WidgetTester tester) async {
    app.main();

    // Trigger a frame.
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_decrementButtonKey));

    await tester.pumpAndSettle();

    expect(find.text('-1'), findsOneWidget);
  });
}
