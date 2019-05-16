import 'dart:async';
import 'dart:math';
import 'package:flutter_complex_list/models/models.dart';

class Repository {
  final _random = Random();

  int _next(int min, int max) => min + _random.nextInt(max - min);

  Future<List<Item>> fetchItems() async {
    await Future.delayed(Duration(seconds: _next(1, 5)));
    return List.of(_generateItemsList(10));
  }

  List<Item> _generateItemsList(int numItems) {
    final List<Item> items = [];
    for (int i = 0; i < numItems; i++) {
      items.add(Item(id: i.toString(), value: 'Item $i'));
    }
    return items;
  }

  Stream<String> deleteItem(String id) async* {
    await Future.delayed(Duration(seconds: _next(1, 5)));
    yield id;
  }
}
