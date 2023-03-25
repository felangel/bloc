import 'dart:async';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc(this._shoppingRepository) : super(const ProductListState()) {
    on<_ProductListCartProductsChanged>(_onCartProductsChanged);
    on<ProductListStarted>(_onStarted);
    on<ProductListProductAdded>(_onProductAdded);
    on<ProductListProductRemoved>(_onProductRemoved);

    _productSubscription = _shoppingRepository.selectedProducts.listen(
      (products) => add(
        _ProductListCartProductsChanged(products),
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

  void _onCartProductsChanged(
    _ProductListCartProductsChanged event,
    Emitter<ProductListState> emit,
  ) {
    emit(
      state.copyWith(
        selectedProducts: event.products,
      ),
    );
  }

  Future<void> _onStarted(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      late final List<Product> allProducts;
      late final List<Product> cartProducts;

      await Future.wait([
        _shoppingRepository.fetchAllProducts().then((products) {
          allProducts = products;
        }),
        _shoppingRepository.fetchCartProducts().then((products) {
          cartProducts = products;
        }),
      ]);

      emit(
        state.copyWith(
          status: ProductListStatus.success,
          allProducts: allProducts,
          selectedProducts: cartProducts,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProductListStatus.failure,
        ),
      );
    }
  }

  Future<void> _onProductAdded(
    ProductListProductAdded event,
    Emitter<ProductListState> emit,
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
          selectedProducts: [product, ...state.selectedProducts],
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
    ProductListProductRemoved event,
    Emitter<ProductListState> emit,
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
          selectedProducts: [...state.selectedProducts]..remove(product),
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
}
