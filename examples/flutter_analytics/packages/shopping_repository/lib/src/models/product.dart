import 'package:equatable/equatable.dart';

/// {@template product}
/// A generic product.
/// {@endtemplate}
class Product extends Equatable {
  /// {@macro product}
  const Product(
    this.id,
    this.name, {
    this.price = 42,
  });

  /// The unique identifier of the product.
  final int id;

  /// The name of the product.
  final String name;

  /// The price of the product.
  final int price;

  /// Represents an empty product.
  static const empty = Product(0, '');

  @override
  List<Object> get props => [id, name, price];
}
