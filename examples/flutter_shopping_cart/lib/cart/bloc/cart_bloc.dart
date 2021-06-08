import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/cart/cart.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:flutter_shopping_cart/shopping_repository.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({required this.shoppingRepository}) : super(CartLoading());

  final ShoppingRepository shoppingRepository;

  @override
  Stream<CartState> mapEventToState(
    CartEvent event,
  ) async* {
    if (event is CartStarted) {
      yield* _mapCartStartedToState();
    } else if (event is CartItemAdded) {
      yield* _mapCartItemAddedToState(event, state);
    }
  }

  Stream<CartState> _mapCartStartedToState() async* {
    yield CartLoading();
    try {
      await shoppingRepository.loadCart();
      yield const CartLoaded();
    } catch (_) {
      yield CartError();
    }
  }

  Stream<CartState> _mapCartItemAddedToState(
    CartItemAdded event,
    CartState state,
  ) async* {
    if (state is CartLoaded) {
      try {
        await shoppingRepository.addItemToCart(event.item);
        yield CartLoaded(
          cart: Cart(items: List.from(state.cart.items)..add(event.item)),
        );
      } on Exception {
        yield CartError();
      }
    }
  }
}
