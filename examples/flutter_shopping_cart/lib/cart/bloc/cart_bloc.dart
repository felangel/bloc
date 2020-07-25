import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_shopping_cart/catalog/catalog.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartLoading());

  @override
  Stream<CartState> mapEventToState(
    CartEvent event,
  ) async* {
    if (event is CartStarted) {
      yield* _mapCartStartedToState();
    } else if (event is CartItemAdded) {
      yield* _mapCartItemAddedToState(event);
    }
  }

  Stream<CartState> _mapCartStartedToState() async* {
    yield CartLoading();
    try {
      await Future.delayed(Duration(seconds: 1));
      yield CartLoaded(items: []);
    } catch (_) {
      yield CartError();
    }
  }

  Stream<CartState> _mapCartItemAddedToState(CartItemAdded event) async* {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        yield CartLoaded(
          items: List.from(currentState.items)..add(event.item),
        );
      } catch (_) {
        yield CartError();
      }
    }
  }
}
