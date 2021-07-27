import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Item', () {
    test('supports value comparison', () async {
      expect(Item(1, 'item #1'), Item(1, 'item #1'));
    });
  });
}
