part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class _CartProductsChanged extends CartEvent {
  const _CartProductsChanged(this.products);

  final List<Product> products;

  @override
  List<Object> get props => [products];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartProductRemoved extends CartEvent with Analytic {
  const CartProductRemoved(this.product);

  final Product product;

  @override
  String get eventName => 'cart_product_removed';

  @override
  Map<String, dynamic> get parameters => {
        'product_id': product.id,
        'product_name': product.name,
        'product_price': product.price,
      };

  @override
  List<Object> get props => [product];
}

class CartClearRequested extends CartEvent with Analytic {
  const CartClearRequested();

  @override
  String get eventName => 'cart_cleared';
}
