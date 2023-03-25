import 'package:equatable/equatable.dart';

/// {@template offer}
/// A generic offer.
/// {@endtemplate}
class Offer extends Equatable {
  /// {@macro offer}
  const Offer({
    required this.id,
    required this.title,
    required this.description,
  });

  /// The unique identifier of the offer.
  final int id;

  /// The title of the offer.
  final String title;

  /// The description of the offer.
  final String description;

  @override
  List<Object> get props => [id, title, description];
}
