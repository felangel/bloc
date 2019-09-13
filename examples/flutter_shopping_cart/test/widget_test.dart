import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_shopping_cart/main.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    await tester.pumpWidget(MyApp());

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    expect(find.text('\$0'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    expect(find.text('\$0'), findsNothing);
  });
}
