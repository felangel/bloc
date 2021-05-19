import 'package:flutter_timer/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders Timer', (tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(Timer), findsOneWidget);
    });
  });
}
