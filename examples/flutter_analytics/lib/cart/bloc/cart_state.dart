part of 'cart_bloc.dart';

enum CartStatus {
  loading,
  success,
  failure,
}

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.loading,
    this.products = const [],
    this.pendingProduct = Product.empty,
  });

  final CartStatus status;
  final List<Product> products;
  final Product pendingProduct;

  int get totalPrice {
    return products.fold(0, (total, current) => total + current.price);
  }

  CartState copyWith({
    CartStatus? status,
    List<Product>? products,
    Product? pendingProduct,
  }) {
    return CartState(
      status: status ?? this.status,
      products: products ?? this.products,
      pendingProduct: pendingProduct ?? this.pendingProduct,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        pendingProduct,
      ];
}
