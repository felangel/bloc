part of 'cart_bloc.dart';

@immutable
abstract class CartEvent extends Equatable {
  const CartEvent();
}

class CartStarted extends CartEvent {
  @override
  List<Object> get props => [];
}

class CartItemAdded extends CartEvent {
  final Item item;

  const CartItemAdded(this.item);

  @override
  List<Object> get props => [item];
}
