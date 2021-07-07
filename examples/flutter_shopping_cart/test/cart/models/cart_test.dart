import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cart', () {
    final mockItems = [
      Item(1, 'item #1'),
      Item(2, 'item #2'),
      Item(3, 'item #3'),
    ];

    test('supports value comparison', () async {
      expect(Cart(items: mockItems), Cart(items: mockItems));
    });

    test('gets correct total price for 3 items', () async {
      expect(Cart(items: mockItems).totalPrice, 42 * 3);
    });
  });
}
