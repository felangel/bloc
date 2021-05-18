import 'package:flutter_dynamic_form/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders MyForm', (tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(MyForm), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
