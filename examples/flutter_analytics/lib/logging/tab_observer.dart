import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/widgets.dart';

class TabNavigatorObserver extends NavigatorObserver {
  TabNavigatorObserver({
    required this.tabAnalytic,
    required AnalyticsRepository analyticsRepository,
  }) : _analyticsRepository = analyticsRepository;

  final Analytic tabAnalytic;
  final AnalyticsRepository _analyticsRepository;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == Navigator.defaultRouteName) return;
    final arguments = route.settings.arguments;
    if (arguments is Analytic) _analyticsRepository.send(arguments);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final arguments = previousRoute?.settings.arguments;
    final name = previousRoute?.settings.name;

    if (name == Navigator.defaultRouteName) {
      return _analyticsRepository.send(tabAnalytic);
    }
    if (arguments is Analytic) _analyticsRepository.send(arguments);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final arguments = previousRoute?.settings.arguments;
    if (arguments is Analytic) _analyticsRepository.send(arguments);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final arguments = newRoute?.settings.arguments;
    if (arguments is Analytic) _analyticsRepository.send(arguments);
  }
}
