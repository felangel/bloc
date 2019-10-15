import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  @override
  CartState get initialState => CartLoading();

  @override
  Stream<CartState> mapEventToState(
    CartEvent event,
  ) async* {
    if (event is LoadCart) {
      yield* _mapLoadCartToState();
    } else if (event is AddItem) {
      yield* _mapAddItemToState(event);
    }
  }

  Stream<CartState> _mapLoadCartToState() async* {
    yield CartLoading();
    try {
      await Future.delayed(Duration(seconds: 1));
      yield CartLoaded(items: []);
    } catch (_) {
      yield CartError();
    }
  }

  Stream<CartState> _mapAddItemToState(AddItem event) async* {
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
