// ignore_for_file: prefer_const_constructors
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CatalogEvent', () {
    group('CatalogStarted', () {
      test('supports value comparison', () {
        expect(CatalogStarted(), CatalogStarted());
      });
    });
  });
}
