import 'dart:async';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._shoppingRepository) : super(const CartState()) {
    on<_CartProductsChanged>(_onProductsChanged);
    on<CartStarted>(_onStarted);
    on<CartProductAdded>(_onProductAdded);
    on<CartProductRemoved>(_onProductRemoved);
    on<CartClearRequested>(_onClearRequested);

    _productSubscription = _shoppingRepository.selectedProducts.listen(
      (products) => add(
        _CartProductsChanged(products),
      ),
    );
  }

  final ShoppingRepository _shoppingRepository;
  late StreamSubscription<List<Product>> _productSubscription;

  @override
  Future<void> close() {
    _productSubscription.cancel();
    return super.close();
  }

  void _onProductsChanged(
    _CartProductsChanged event,
    Emitter<CartState> emit,
  ) {
    emit(
      state.copyWith(
        products: event.products,
      ),
    );
  }

  Future<void> _onStarted(
    CartStarted event,
    Emitter<CartState> emit,
  ) async {
    try {
      final products = await _shoppingRepository.fetchCartProducts();

      emit(
        state.copyWith(
          status: CartStatus.success,
          products: products,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
        ),
      );
    }
  }

  Future<void> _onProductAdded(
    CartProductAdded event,
    Emitter<CartState> emit,
  ) async {
    final product = event.product;

    emit(
      state.copyWith(
        pendingProduct: product,
      ),
    );

    try {
      await _shoppingRepository.addProductToCart(product);

      emit(
        state.copyWith(
          pendingProduct: Product.empty,
          products: [product, ...state.products],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          pendingProduct: Product.empty,
        ),
      );
    }
  }

  Future<void> _onProductRemoved(
    CartProductRemoved event,
    Emitter<CartState> emit,
  ) async {
    final product = event.product;

    emit(
      state.copyWith(
        pendingProduct: product,
      ),
    );

    try {
      await _shoppingRepository.removeProductFromCart(product);

      emit(
        state.copyWith(
          pendingProduct: Product.empty,
          products: [...state.products]..remove(product),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          pendingProduct: Product.empty,
        ),
      );
    }
  }

  Future<void> _onClearRequested(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CartStatus.loading,
      ),
    );

    try {
      await _shoppingRepository.clearCart();

      emit(
        state.copyWith(
          status: CartStatus.success,
          products: [],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
        ),
      );
    }
  }
}
