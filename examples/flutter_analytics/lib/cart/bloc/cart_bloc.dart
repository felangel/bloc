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
    on<CartStarted>(_onCartStarted);
    on<CartProductAdded>(_onProductAdded);
    on<CartProductRemoved>(_onProductRemoved);
    on<CartClearRequested>(_onCartClearRequested);
    on<CartCheckoutRequested>(_onCartCheckoutRequested);
    on<CartCheckoutCanceled>(_onCartCheckoutCanceled);

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

  Future<void> _onCartStarted(
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
    } catch (e) {
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
    if (state.pendingProduct == event.product) return;

    emit(
      state.copyWith(
        pendingProduct: event.product,
      ),
    );

    try {
      await _shoppingRepository.addProductToCart(event.product);
    } finally {
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
    if (state.pendingProduct == event.product) return;

    emit(
      state.copyWith(
        pendingProduct: event.product,
      ),
    );

    try {
      await _shoppingRepository.removeProductFromCart(event.product);
    } finally {
      emit(
        state.copyWith(
          pendingProduct: Product.empty,
        ),
      );
    }
  }

  Future<void> _onCartClearRequested(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state.status == CartStatus.loading) return;
    if (state.products.isEmpty) return;

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
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
        ),
      );
    }
  }

  Future<void> _onCartCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(
      state.copyWith(
        isCheckout: true,
      ),
    );
  }

  void _onCartCheckoutCanceled(
    CartCheckoutCanceled event,
    Emitter<CartState> emit,
  ) {
    emit(
      state.copyWith(
        isCheckout: false,
      ),
    );
  }
}
