part of 'product_list_bloc.dart';

enum ProductListStatus {
  loading,
  success,
  failure,
}

class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.loading,
    this.allProducts = const [],
    this.selectedProducts = const [],
    this.pendingProduct = Product.empty,
  });

  final ProductListStatus status;
  final List<Product> allProducts;
  final List<Product> selectedProducts;
  final Product pendingProduct;

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? allProducts,
    List<Product>? selectedProducts,
    Product? pendingProduct,
  }) {
    return ProductListState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      pendingProduct: pendingProduct ?? this.pendingProduct,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allProducts,
        selectedProducts,
        pendingProduct,
      ];
}
