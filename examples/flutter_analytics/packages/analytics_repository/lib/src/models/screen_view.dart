import 'package:analytics_repository/analytics_repository.dart';

/// {@template screen_view}
/// An [Analytic] that represents a screen view.
/// {@endtemplate}
class ScreenView with Analytic {
  /// {@macro screen_view}
  const ScreenView({
    required this.routeName,
    this.parameters = const {},
  });

  /// The name of the route.
  final String routeName;

  @override
  final Map<String, dynamic> parameters;

  @override
  String get eventName => '${routeName}_viewed';
}
