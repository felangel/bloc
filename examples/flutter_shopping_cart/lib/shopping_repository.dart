import 'dart:async';

import 'package:flutter_shopping_cart/catalog/catalog.dart';

const _delay = Duration(milliseconds: 800);
Future<void> wait() => Future.delayed(_delay);

class ShoppingRepository {
  Future<List<String>> fetchCatalog() async {
    await wait();
    return [
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
  }

  Future<void> loadCart() async {
    return wait();
  }

  Future<void> addItemToCart(Item item) async {
    return wait();
  }
}
