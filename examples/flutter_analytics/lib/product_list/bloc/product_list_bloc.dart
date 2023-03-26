import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc(this._shoppingRepository) : super(const ProductListState()) {
    on<ProductListStarted>(_onStarted);
  }

  final ShoppingRepository _shoppingRepository;

  Future<void> _onStarted(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      final products = await _shoppingRepository.fetchAllProducts();

      emit(
        state.copyWith(
          status: ProductListStatus.success,
          products: products,
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
}
