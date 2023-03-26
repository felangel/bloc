import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';

/// {@template analytic_route_settings}
/// [RouteSettings] that contain a [ScreenView].
/// {@endtemplate}
class AnalyticRouteSettings extends RouteSettings {
  /// {@macro analytic_route_settings}
  const AnalyticRouteSettings({
    required this.screenView,
    super.name,
    super.arguments,
  });

  /// An [Analytic] that represents a route that was viewed.
  final ScreenView screenView;
}
