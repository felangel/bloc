import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';

@immutable
class Cart extends Equatable {
  const Cart({this.items = const <Item>[]});

  final List<Item> items;

  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  @override
  List<Object> get props => [items];
}
