// ignore_for_file: prefer_const_constructors
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('CartEvent', () {
    group('CartStarted', () {
      test('supports value comparison', () {
        expect(
          CartStarted(),
          CartStarted(),
        );
      });
    });

    group('CartProductAdded', () {
      test('supports value comparison', () {
        expect(
          CartProductAdded(product),
          CartProductAdded(product),
        );
      });

      test('has event name', () {
        expect(
          CartProductAdded(product).eventName,
          isNotEmpty,
        );
      });

      test('has event parameters', () {
        expect(
          CartProductAdded(product).parameters,
          isMap.having(
            (map) => map.isNotEmpty,
            'is not empty',
            true,
          ),
        );
      });
    });

    group('CartProductRemoved', () {
      test('supports value comparison', () {
        expect(
          CartProductRemoved(product),
          CartProductRemoved(product),
        );
      });

      test('has event name', () {
        expect(
          CartProductRemoved(product).eventName,
          isNotEmpty,
        );
      });

      test('has event parameters', () {
        expect(
          CartProductRemoved(product).parameters,
          isMap.having(
            (map) => map.isNotEmpty,
            'is not empty',
            true,
          ),
        );
      });
    });

    group('CartProductRemoved', () {
      test('supports value comparison', () {
        expect(
          CartProductRemoved(product),
          CartProductRemoved(product),
        );
      });

      test('has event name', () {
        expect(
          CartProductRemoved(product).eventName,
          isNotEmpty,
        );
      });
    });

    group('CartClearRequested', () {
      test('supports value comparison', () {
        expect(
          CartClearRequested(),
          CartClearRequested(),
        );
      });

      test('has event name', () {
        expect(
          CartClearRequested().eventName,
          isNotEmpty,
        );
      });
    });
  });
}
