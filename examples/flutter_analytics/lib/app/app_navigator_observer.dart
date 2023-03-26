import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/widgets.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._analyticsRepository);

  final AnalyticsRepository _analyticsRepository;

  void _maybeSendScreenView(Route<dynamic>? route) {
    final settings = route?.settings;
    if (settings is AnalyticRouteSettings) {
      _analyticsRepository.send(settings.screenView);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.isFirst) return;
    _maybeSendScreenView(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _maybeSendScreenView(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _maybeSendScreenView(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _maybeSendScreenView(newRoute);
  }
}
