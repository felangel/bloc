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
    this.isCheckout = false,
  });

  final CartStatus status;
  final List<Product> products;
  final Product pendingProduct;

  final bool isCheckout;

  int get totalPrice {
    return products.fold(0, (total, current) => total + current.price);
  }

  CartState copyWith({
    CartStatus? status,
    List<Product>? products,
    Product? pendingProduct,
    bool? isCheckout,
  }) {
    return CartState(
      status: status ?? this.status,
      products: products ?? this.products,
      pendingProduct: pendingProduct ?? this.pendingProduct,
      isCheckout: isCheckout ?? this.isCheckout,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        pendingProduct,
        isCheckout,
      ];
}
