import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required this.shoppingRepository}) : super(CartLoading()) {
    on<CartStarted>(_onCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
  }

  final ShoppingRepository shoppingRepository;

  Future<void> _onCartStarted(CartStarted event, Emitter emit) async {
    emit(CartLoading());
    try {
      final items = await shoppingRepository.loadCartItems();
      emit(CartLoaded(cart: Cart(items: [...items])));
    } catch (_) {
      emit(CartError());
    }
  }

  void _onCartItemAdded(CartItemAdded event, Emitter emit) async {
    if (state is CartLoaded) {
      final cart = (state as CartLoaded).cart;
      try {
        shoppingRepository.addItemToCart(event.item);
        emit(CartLoaded(cart: Cart(items: [...cart.items, event.item])));
      } on Exception {
        emit(CartError());
      }
    }
  }
}
