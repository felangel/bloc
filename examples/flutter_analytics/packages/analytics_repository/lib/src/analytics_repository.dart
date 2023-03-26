import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';

/// {@template analytics_repository}
/// A repository that handles analytics.
/// {@endtemplate}
class AnalyticsRepository {
  /// {@macro analytics_repository}
  const AnalyticsRepository();

  /// Sends an [Analytic] to an analytics service.
  void send(Analytic analytic) {
    var event = analytic.eventName;
    if (analytic.parameters.isNotEmpty) event += ', ${analytic.parameters}';
    log(event);
  }
}
