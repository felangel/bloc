// ignore_for_file: prefer_const_constructors
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEvent', () {
    group('AppTabPressed', () {
      test('supports value comparison', () {
        expect(
          AppTabPressed(AppTab.offers),
          AppTabPressed(AppTab.offers),
        );
      });

      test('has event name', () {
        for (final tab in AppTab.values) {
          expect(
            AppTabPressed(tab).eventName,
            isNotEmpty,
          );
        }
      });
    });
  });
}
