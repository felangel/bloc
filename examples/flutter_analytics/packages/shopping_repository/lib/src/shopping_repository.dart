import 'dart:async';

import 'package:shopping_repository/shopping_repository.dart';

/// {@template shopping_repository}
/// A repository that handles shopping-related requests.
/// {@endtemplate}
class ShoppingRepository {
  /// {@macro shopping_repository}
  ShoppingRepository();

  List<Product> _products = [];

  final _controller = StreamController<List<Product>>.broadcast();

  /// A stream of the list of products that are in the cart.
  Stream<List<Product>> get selectedProducts async* {
    yield* _controller.stream;
  }

  void _update(List<Product> products) {
    _products = products;
    _controller.add(products);
  }

  /// Fetches a list of products in the cart.
  Future<List<Product>> fetchCartProducts() async {
    final products = await Future.delayed(_shortDelay, () => [..._products]);
    _update(products);
    return products;
  }

  /// Adds a product to the cart.
  Future<void> addProductToCart(Product product) async {
    final products = await Future.delayed(
      _shortDelay,
      () => [product, ..._products],
    );

    _update(products);
  }

  /// Adds an offer to the cart.
  Future<void> addOfferToCart(Offer offer) async {
    final products = await Future.delayed(
      _shortDelay,
      () => [offer.product, ..._products],
    );

    _update(products);
  }

  /// Removes a product from the cart.
  Future<void> removeProductFromCart(Product product) async {
    final products = await Future.delayed(
      _shortDelay,
      () => [..._products]..remove(product),
    );

    _update(products);
  }

  /// Clears the cart.
  Future<void> clearCart() async {
    final products = await Future.delayed(_shortDelay, () => <Product>[]);
    _update(products);
  }

  /// Fetches a list of all products.
  Future<List<Product>> fetchAllProducts() async {
    final allProducts = await Future.delayed(_longDelay, () => _allProducts);
    return allProducts;
  }

  /// Fetches a list of offers.
  Future<List<Offer>> fetchOffers() async {
    final offers = await Future.delayed(_longDelay, () => _offers);
    return offers;
  }
}

const _longDelay = Duration(milliseconds: 800);
const _shortDelay = Duration(milliseconds: 300);

final _offers = [
  const Offer(
    id: 0,
    product: Product(1, 'Primitive Obsession', price: 21),
    title: '50% off!',
    subtitle: 'Primitive Obsession',
    description: 'A code smell for the primitive soul in all of us.',
  ),
  const Offer(
    id: 1,
    product: Product(3, 'Divergent Change'),
    title: 'In stock again',
    subtitle: 'Divergent Change',
    description: 'The original code smell, finally available again.',
  ),
];

const _allProducts = [
  Product(0, 'Speculative Generality'),
  Product(1, 'Primitive Obsession', price: 21),
  Product(2, 'Data Clumps'),
  Product(3, 'Divergent Change'),
  Product(4, 'Long Parameter List'),
  Product(5, 'Shotgun Surgery'),
  Product(6, 'Duplicate Code'),
  Product(7, 'Refused Bequest'),
  Product(8, 'Dead Code'),
  Product(9, 'Lazy Class'),
  Product(10, 'Long method'),
  Product(11, 'Feature Envy'),
  Product(12, 'Inappropriate Intimacy'),
  Product(13, 'Message Chains'),
  Product(14, 'Middle Man'),
];
