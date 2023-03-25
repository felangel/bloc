import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// {@template product}
/// A generic product.
/// {@endtemplate}
class Product extends Equatable {
  /// {@macro product}
  Product(this.id, this.name)
      : color = Colors.primaries[id % Colors.primaries.length];

  /// The unique identifier of the product.
  final int id;

  /// The name of the product.
  final String name;

  /// The color of the product.
  final Color color;

  /// The price of the product.
  final int price = 42;

  @override
  List<Object> get props => [id, name, color, price];
}
