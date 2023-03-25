import 'package:equatable/equatable.dart';

/// {@template product}
/// A generic product.
/// {@endtemplate}
class Product extends Equatable {
  /// {@macro product}
  const Product({
    required this.id,
    required this.name,
    required this.description,
    this.price = 42,
  });

  /// The unique identifier of the product.
  final int id;

  /// The name of the product.
  final String name;

  /// The price of the product.
  final int price;

  /// The description of the product.
  final String description;

  /// Represents an empty product.
  static const empty = Product(id: 0, name: '', description: '');

  @override
  List<Object> get props => [id, name, price];
}
