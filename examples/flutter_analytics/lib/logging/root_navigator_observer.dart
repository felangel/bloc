import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/widgets.dart';

class RootNavigatorObserver extends NavigatorObserver {
  RootNavigatorObserver(this._analyticsRepository);

  final AnalyticsRepository _analyticsRepository;

  void _maybeSendAnalytic(Route<dynamic>? route) {
/*     final arguments = route?.settings.arguments;
    if (arguments is Analytic) _analyticsRepository.send(arguments); */
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _maybeSendAnalytic(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _maybeSendAnalytic(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _maybeSendAnalytic(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _maybeSendAnalytic(newRoute);
  }
}
