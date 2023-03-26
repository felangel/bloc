import 'package:equatable/equatable.dart';
import 'package:shopping_repository/shopping_repository.dart';

/// {@template offer}
/// A generic offer.
/// {@endtemplate}
class Offer extends Equatable {
  /// {@macro offer}
  const Offer({
    required this.id,
    required this.product,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  /// The unique identifier of the offer.
  final int id;

  /// The product associated with the offer.
  final Product product;

  /// The title of the offer.
  final String title;

  /// The subtitle of the offer.
  final String subtitle;

  /// The description of the offer.
  final String description;

  /// Represents an empty offer.
  static const empty = Offer(
    id: 0,
    product: Product.empty,
    title: '',
    subtitle: '',
    description: '',
  );

  @override
  List<Object> get props => [id, title, description];
}
