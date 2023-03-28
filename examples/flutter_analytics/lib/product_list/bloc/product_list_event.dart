part of 'product_list_bloc.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object> get props => [];
}

class _ProductListCartProductsChanged extends ProductListEvent {
  const _ProductListCartProductsChanged(this.products);

  final List<Product> products;

  @override
  List<Object> get props => [products];
}

class ProductListStarted extends ProductListEvent {
  const ProductListStarted();
}

class ProductListProductAdded extends ProductListEvent with Analytic {
  const ProductListProductAdded(this.product);

  final Product product;

  @override
  String get eventName => 'product_added';

  @override
  Map<String, dynamic> get parameters => {
        'product_id': product.id,
        'product_name': product.name,
        'product_price': product.price,
      };

  @override
  List<Object> get props => [product];
}

class ProductListProductRemoved extends ProductListEvent with Analytic {
  const ProductListProductRemoved(this.product);

  final Product product;

  @override
  String get eventName => 'product_removed';

  @override
  Map<String, dynamic> get parameters => {
        'product_id': product.id,
        'product_name': product.name,
        'product_price': product.price,
      };

  @override
  List<Object> get props => [product];
}
