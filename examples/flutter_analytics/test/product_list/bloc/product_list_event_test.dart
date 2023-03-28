// ignore_for_file: prefer_const_constructors
import 'package:flutter_analytics/product_list/product_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('ProductListEvent', () {
    group('ProductListStarted', () {
      test('supports value comparison', () {
        expect(
          ProductListStarted(),
          ProductListStarted(),
        );
      });
    });

    group('ProductListProductAdded', () {
      test('supports value comparison', () {
        expect(
          ProductListProductAdded(product),
          ProductListProductAdded(product),
        );
      });

      test('has event name', () {
        expect(
          ProductListProductAdded(product).eventName,
          isNotEmpty,
        );
      });

      test('has event parameters', () {
        expect(
          ProductListProductAdded(product).parameters,
          isMap.having(
            (map) => map.isNotEmpty,
            'is not empty',
            true,
          ),
        );
      });
    });

    group('ProductListProductRemoved', () {
      test('supports value comparison', () {
        expect(
          ProductListProductRemoved(product),
          ProductListProductRemoved(product),
        );
      });

      test('has event name', () {
        expect(
          ProductListProductRemoved(product).eventName,
          isNotEmpty,
        );
      });

      test('has event parameters', () {
        expect(
          ProductListProductRemoved(product).parameters,
          isMap.having(
            (map) => map.isNotEmpty,
            'is not empty',
            true,
          ),
        );
      });
    });
  });
}
