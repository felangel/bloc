part of 'product_list_bloc.dart';

enum ProductListStatus {
  loading,
  success,
  failure,
}

class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.loading,
    this.products = const [],
  });

  final ProductListStatus status;
  final List<Product> products;

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    Product? selectedProduct,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [status, products];
}
