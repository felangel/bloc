import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CartState extends Equatable {
  CartState([List props = const <dynamic>[]]) : super(props);
}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Item> items;

  CartLoaded({this.items}) : super([items]);

  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);
}

class CartError extends CartState {}
