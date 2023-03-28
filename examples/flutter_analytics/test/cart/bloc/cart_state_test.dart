// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('CartState', () {
    test('supports value comparison', () {
      expect(CartState(), CartState());
    });

    test('returns correct total price', () {
      expect(
        CartState(
          products: const [
            Product(
              id: 0,
              name: 'name',
              description: 'description',
              price: 42,
            ),
            Product(
              id: 0,
              name: 'name',
              description: 'description',
              price: 42,
            ),
          ],
        ).totalPrice,
        equals(84),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          CartState().copyWith(),
          equals(CartState()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          CartState().copyWith(
            status: null,
            products: null,
            pendingProduct: null,
          ),
          equals(CartState()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          CartState().copyWith(
            status: CartStatus.success,
            products: [product],
            pendingProduct: product,
          ),
          equals(
            CartState(
              status: CartStatus.success,
              products: const [product],
              pendingProduct: product,
            ),
          ),
        );
      });
    });
  });
}
