import 'package:analytics_repository/analytics_repository.dart';

/// {@template route_analytic}
/// A class that represents an analytics event for a route.
/// {@endtemplate}
class RouteAnalytic with Analytic {
  /// {@macro route_analytic}
  const RouteAnalytic(
    this.eventName, [
    this.parameters = const {},
  ]);

  @override
  final String eventName;

  @override
  final Map<String, dynamic> parameters;
}
