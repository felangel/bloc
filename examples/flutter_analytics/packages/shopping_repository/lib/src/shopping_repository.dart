import 'package:shopping_repository/shopping_repository.dart';

/// {@template shopping_repository}
/// A repository that handles shopping-related requests.
/// {@endtemplate}
class ShoppingRepository {
  /// {@macro shopping_repository}
  const ShoppingRepository();

  /// Fetches a list of products.
  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(_delay);
    return _products;
  }

  /// Fetches a list of offers.
  Future<List<Offer>> fetchOffers() async {
    await Future<void>.delayed(_delay);
    return _offers;
  }
}

const _delay = Duration(milliseconds: 800);

final _offers = [
  const Offer(
    id: 0,
    title: 'Buy 1, get 1 free',
    description: 'Buy one, get one free on all code smells',
  ),
  const Offer(
    id: 1,
    title: '20% off',
    description: '20% off on all couplers',
  ),
];

final _products = [
  Product(0, 'Speculative Generality'),
  Product(1, 'Primitive Obsession'),
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
