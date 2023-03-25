import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_repository/shopping_repository.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockAppBloc extends Mock implements AppBloc {}

extension PumpApp on WidgetTester {
  Widget createSubject({
    required Widget child,
    ShoppingRepository? shoppingRepository,
    AnalyticsRepository? analyticsRepository,
    AppBloc? appBloc,
  }) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: shoppingRepository ?? MockShoppingRepository(),
        ),
        RepositoryProvider.value(
          value: analyticsRepository ?? MockAnalyticsRepository(),
        ),
      ],
      child: BlocProvider.value(
        value: appBloc ?? MockAppBloc(),
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  Future<void> pumpApp(
    Widget widget, {
    ShoppingRepository? shoppingRepository,
    AnalyticsRepository? analyticsRepository,
    AppBloc? appBloc,
  }) {
    return pumpWidget(
      createSubject(
        child: widget,
        shoppingRepository: shoppingRepository,
        analyticsRepository: analyticsRepository,
        appBloc: appBloc,
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    ShoppingRepository? shoppingRepository,
    AnalyticsRepository? analyticsRepository,
    AppBloc? appBloc,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      shoppingRepository: shoppingRepository,
      analyticsRepository: analyticsRepository,
      appBloc: appBloc,
    );
  }
}
