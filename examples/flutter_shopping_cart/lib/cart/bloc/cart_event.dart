import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CartEvent extends Equatable {
  CartEvent([List props = const <dynamic>[]]) : super(props);
}

class LoadCart extends CartEvent {}

class AddItem extends CartEvent {
  final Item item;

  AddItem(this.item) : super([item]);
}
