import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShoppingRepository', () {
    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = ShoppingRepository();
    });

    group('fetchCatalog', () {
      test('returns list of item names', () {
        final items = [
          'Code Smell',
          'Control Flow',
          'Interpreter',
          'Recursion',
          'Sprint',
          'Heisenbug',
          'Spaghetti',
          'Hydra Code',
          'Off-By-One',
          'Scope',
          'Callback',
          'Closure',
          'Automata',
          'Bit Shift',
          'Currying',
        ];
        expect(
          shoppingRepository.fetchCatalog(),
          completion(equals(items)),
        );
      });
    });

    group('loadCart', () {
      test('return null after loading cart', () {
        expect(
          shoppingRepository.loadCart(),
          completion(equals(null)),
        );
      });
    });

    group('addItemToCart', () {
      test('return null after adding item to cart', () {
        final item = Item(1, 'item #1');
        expect(
          shoppingRepository.addItemToCart(item),
          completion(equals(null)),
        );
      });
    });
  });
}
