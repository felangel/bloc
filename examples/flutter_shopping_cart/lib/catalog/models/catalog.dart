import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';

@immutable
class Catalog extends Equatable {
  static const _itemNames = [
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

  Item getById(int id) => Item(id, _itemNames[id % _itemNames.length]);

  Item getByPosition(int position) => getById(position);

  @override
  List<Object> get props => [_itemNames];
}
