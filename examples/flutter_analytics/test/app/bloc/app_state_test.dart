// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppState', () {
    test('supports value comparison', () {
      expect(AppState(), AppState());
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          AppState().copyWith(),
          equals(AppState()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          AppState().copyWith(currentTab: null),
          equals(AppState()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          AppState().copyWith(currentTab: AppTab.offers),
          equals(AppState(currentTab: AppTab.offers)),
        );
      });
    });
  });
}
