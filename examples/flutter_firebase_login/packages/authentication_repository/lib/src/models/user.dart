import 'package:equatable/equatable.dart';

/// {@template user}
/// User model
///
/// [User.anonymous] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
  });

  /// The current user's email address.
  final String? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Anonymous user which represents an unauthenticated user.
  static const anonymous = User(id: '');

  /// Convenience getter to determine whether the current user is anonymous.
  bool get isAnonymous => this == User.anonymous;

  /// Convenience getter to determine whether the current user is not anonymous.
  bool get isNotAnonymous => this != User.anonymous;

  @override
  List<Object?> get props => [email, id, name, photo];
}
