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
  final List<Item> items;

  const CartLoaded({this.items});

  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  @override
  List<Object> get props => [items];
}

class CartError extends CartState {
  @override
  List<Object> get props => [];
}
