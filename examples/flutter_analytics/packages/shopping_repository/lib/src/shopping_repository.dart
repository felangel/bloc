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
    description: 'Sometimes code is created “just in case” to support '
        'anticipated future features that never get implemented. As a result, '
        'code becomes hard to understand and support.',
  ),
  Product(
    id: 1,
    name: 'Primitive Obsession',
    description: 'Like most other smells, primitive obsessions are born '
        'in moments of weakness. “Just a field for storing some data!” '
        'the programmer said. Creating a primitive field is so much easier '
        'than making a whole new class, right? And so it was done. '
        'Then another field was needed and added in the same way. '
        'Lo and behold, the class became huge and unwieldy.',
    price: 21,
  ),
  Product(
    id: 2,
    name: 'Data Clumps',
    description: 'Often these data groups are due to poor program '
        'structure or "copypasta programming”. '
        'If you want to make sure whether or not some data is a data clump, '
        'just delete one of the data values and see whether the other '
        'values still make sense. If this isnt the case, this is a good sign '
        'that this group of variables should be combined into an object.',
  ),
  Product(
    id: 3,
    name: 'Divergent Change',
    description: 'You find yourself having to change many unrelated '
        'methods when you make changes to a class. For example, '
        'when adding a new product type you have to change the methods '
        'for finding, displaying, and ordering products.',
  ),
  Product(
    id: 4,
    name: 'Long Parameter List',
    description: 'Lorem Ipsum is simply dummy text of the printing '
        'and typesetting industry. Lorem Ipsum has been the industrys '
        'standard dummy text ever since the 1500s, when an unknown printer '
        'took a galley of type and scrambled it to make a type specimen book. ',
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
