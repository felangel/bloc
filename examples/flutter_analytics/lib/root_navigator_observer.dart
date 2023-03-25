import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/widgets.dart';

class RootNavigatorObserver extends NavigatorObserver {
  RootNavigatorObserver(this._analyticsRepository);

  final AnalyticsRepository _analyticsRepository;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name == Navigator.defaultRouteName) return;
    log('${name}_viewed');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = previousRoute?.settings.name;
    if (name == Navigator.defaultRouteName) return;
    log('${name}_viewed');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = previousRoute?.settings.name;
    if (name == Navigator.defaultRouteName) return;
    log('${name}_viewed');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name;
    if (name == Navigator.defaultRouteName) return;
    log('${name}_viewed');
  }
}
