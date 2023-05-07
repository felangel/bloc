part of 'cart_bloc.dart';

@immutable
sealed class CartState extends Equatable {
  const CartState();
}

final class CartLoading extends CartState {
  @override
  List<Object> get props => [];
}

final class CartLoaded extends CartState {
  const CartLoaded({this.cart = const Cart()});

  final Cart cart;

  @override
  List<Object> get props => [cart];
}

final class CartError extends CartState {
  @override
  List<Object> get props => [];
}
