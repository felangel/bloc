part of 'cart_bloc.dart';

@immutable
sealed class CartEvent extends Equatable {
  const CartEvent();
}

final class CartStarted extends CartEvent {
  @override
  List<Object> get props => [];
}

final class CartItemAdded extends CartEvent {
  const CartItemAdded(this.item);

  final Item item;

  @override
  List<Object> get props => [item];
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.item);

  final Item item;

  @override
  List<Object> get props => [item];
}
