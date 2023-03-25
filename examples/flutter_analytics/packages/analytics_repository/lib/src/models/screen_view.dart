import 'package:analytics_repository/analytics_repository.dart';

/// {@template screen_view}
/// An [Analytic] that represents a screen view.
/// {@endtemplate}
class ScreenView with Analytic {
  /// {@macro screen_view}
  const ScreenView(this.routeName);

  /// The name of the route.
  final String routeName;

  @override
  String get eventName => '${routeName}_viewed';
}
