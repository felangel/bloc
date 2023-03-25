// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values
import 'package:flutter_analytics/product_list/product_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  group('ProductListState', () {
    test('supports value comparison', () {
      expect(ProductListState(), ProductListState());
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          ProductListState().copyWith(),
          equals(ProductListState()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          ProductListState().copyWith(
            status: null,
            allProducts: null,
            selectedProducts: null,
            pendingProduct: null,
          ),
          equals(ProductListState()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          ProductListState().copyWith(
            status: ProductListStatus.success,
            allProducts: [product],
            selectedProducts: [product],
            pendingProduct: product,
          ),
          equals(
            ProductListState(
              status: ProductListStatus.success,
              allProducts: const [product],
              selectedProducts: const [product],
              pendingProduct: product,
            ),
          ),
        );
      });
    });
  });
}
