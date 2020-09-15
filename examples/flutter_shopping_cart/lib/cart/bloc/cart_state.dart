part of 'cart_bloc.dart';

@immutable
abstract class CartState extends Equatable {
  const CartState();
}

class CartLoading extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoaded extends CartState {
  const CartLoaded({this.cart = const Cart()});

  final Cart cart;

  @override
  List<Object> get props => [cart];
}

class CartError extends CartState {
  @override
  List<Object> get props => [];
}
