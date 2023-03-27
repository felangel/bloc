import 'dart:async';
import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_analytics/app/app_bloc_observer.dart';
import 'package:flutter_analytics/app/view/view.dart';
import 'package:shopping_repository/shopping_repository.dart';

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  const analyticsRepository = AnalyticsRepository();
  Bloc.observer = const AppBlocObserver(analyticsRepository);

  final shoppingRepository = ShoppingRepository();

  await runZonedGuarded(
    () async => runApp(
      App(
        analyticsRepository: analyticsRepository,
        shoppingRepository: shoppingRepository,
      ),
    ),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
