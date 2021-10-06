import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShoppingRepository', () {
    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = ShoppingRepository();
    });

    group('loadCatalog', () {
      test('returns list of item names', () {
        const items = [
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
          shoppingRepository.loadCatalog(),
          completion(equals(items)),
        );
      });
    });

    group('loadCartItems', () {
      test('return empty list after loading cart items', () {
        expect(
          shoppingRepository.loadCartItems(),
          completion(equals(<Item>[])),
        );
      });
    });

    group('addItemToCart', () {
      test('returns newly added item after adding item to cart', () {
        final item = Item(1, 'item #1');
        shoppingRepository.addItemToCart(item);
        expect(
          shoppingRepository.loadCartItems(),
          completion(equals([item])),
        );
      });
    });

    group('removeItemFromCart', () {
      test('removes item from cart', () {
        final item = Item(1, 'item #1');
        shoppingRepository
          ..addItemToCart(item)
          ..removeItemFromCart(item);
        expect(
          shoppingRepository.loadCartItems(),
          completion(equals(<Item>[])),
        );
      });
    });
  });
}
