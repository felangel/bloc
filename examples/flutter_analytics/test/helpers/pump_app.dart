import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_repository/shopping_repository.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockAppBloc extends Mock implements AppBloc {}

class MockCartBloc extends Mock implements CartBloc {}

extension PumpApp on WidgetTester {
  Widget createSubject({
    required Widget child,
    ShoppingRepository? shoppingRepository,
    AnalyticsRepository? analyticsRepository,
    AppBloc? appBloc,
    CartBloc? cartBloc,
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: appBloc ?? MockAppBloc(),
          ),
          BlocProvider.value(
            value: cartBloc ?? MockCartBloc(),
          ),
        ],
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
    CartBloc? cartBloc,
  }) {
    return pumpWidget(
      createSubject(
        child: widget,
        shoppingRepository: shoppingRepository,
        analyticsRepository: analyticsRepository,
        appBloc: appBloc,
        cartBloc: cartBloc,
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    ShoppingRepository? shoppingRepository,
    AnalyticsRepository? analyticsRepository,
    AppBloc? appBloc,
    CartBloc? cartBloc,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      shoppingRepository: shoppingRepository,
      analyticsRepository: analyticsRepository,
      appBloc: appBloc,
      cartBloc: cartBloc,
    );
  }
}
