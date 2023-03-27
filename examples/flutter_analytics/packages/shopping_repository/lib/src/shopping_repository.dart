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

const _primitiveObsession = Product(
  id: 1,
  name: 'Primitive Obsession',
  description: '',
  price: 21,
);
const _divergentChange = Product(
  id: 3,
  name: 'Divergent Change',
  description: '',
);

final _offers = [
  const Offer(
    id: 0,
    product: _primitiveObsession,
    title: '50% off!',
    subtitle: 'Primitive Obsession',
    description: 'A code smell for the primitive soul in all of us.',
  ),
  const Offer(
    id: 1,
    product: _divergentChange,
    title: 'In stock again',
    subtitle: 'Divergent Change',
    description: 'The original code smell, finally available again.',
  ),
];

const _allProducts = [
  Product(
    id: 0,
    name: 'Speculative Generality',
    description: 'A code smell that occurs when developers create code '
        'that is overly abstract or generic, in anticipation of future '
        'requirements or use cases that may never materialize. '
        'This can result in code that is more complex and harder to '
        'understand than necessary, leading to increased maintenance '
        'costs and potential bugs. The term "speculative" refers to the '
        'fact that developers are trying to anticipate future needs '
        'rather than focusing on the current requirements.',
  ),
  Product(
    id: 1,
    name: 'Primitive Obsession',
    description: 'When developers use primitive data types, such as strings '
        'or integers, to represent complex concepts or entities instead of '
        'creating new domain-specific classes. This can lead to code that is '
        'hard to understand, maintain, and extend. The term "obsession" '
        'refers to the fact that developers are fixated on using primitive '
        'types and fail to create appropriate abstractions. ',
    price: 21,
  ),
  Product(
    id: 2,
    name: 'Data Clumps',
    description: 'This code smell occurs when developers repeatedly use '
        'the same group of data fields in different parts of the code, leading '
        'to code that is verbose and harder to maintain. To address this, '
        'new classes can be created to represent the related data fields and '
        'encapsulate their behavior, improving modularity and maintainability.',
  ),
  Product(
    id: 3,
    name: 'Divergent Change',
    description: _loremIpsum,
  ),
  Product(
    id: 4,
    name: 'Long Parameter List',
    description: _loremIpsum,
  ),
  Product(
    id: 5,
    name: 'Shotgun Surgery',
    description: _loremIpsum,
  ),
  Product(
    id: 6,
    name: 'Duplicate Code',
    description: _loremIpsum,
  ),
  Product(
    id: 7,
    name: 'Refused Bequest',
    description: _loremIpsum,
  ),
  Product(
    id: 8,
    name: 'Dead Code',
    description: _loremIpsum,
  ),
  Product(
    id: 9,
    name: 'Lazy Class',
    description: _loremIpsum,
  ),
  Product(
    id: 10,
    name: 'Long method',
    description: _loremIpsum,
  ),
  Product(
    id: 11,
    name: 'Feature Envy',
    description: _loremIpsum,
  ),
  Product(
    id: 12,
    name: 'Inappropriate Intimacy',
    description: _loremIpsum,
  ),
  Product(
    id: 13,
    name: 'Message Chains',
    description: _loremIpsum,
  ),
  Product(
    id: 14,
    name: 'Middle Man',
    description: _loremIpsum,
  ),
];

const _loremIpsum = 'Lorem Ipsum is simply dummy text of the printing '
    'and typesetting industry. Lorem Ipsum has been the industrys '
    'standard dummy text ever since the 1500s, when an unknown printer '
    'took a galley of type and scrambled it to make a type specimen book. ';
