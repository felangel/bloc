import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

class App extends StatelessWidget {
  const App({
    required AnalyticsRepository analyticsRepository,
    required ShoppingRepository shoppingRepository,
    super.key,
  })  : _analyticsRepository = analyticsRepository,
        _shoppingRepository = shoppingRepository;

  final AnalyticsRepository _analyticsRepository;
  final ShoppingRepository _shoppingRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _analyticsRepository),
        RepositoryProvider.value(value: _shoppingRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppBloc(),
          ),
        ],
        child: MaterialApp(
          navigatorObservers: [
            AppNavigatorObserver(_analyticsRepository),
          ],
          theme: ThemeData(
            appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
            colorScheme: ColorScheme.fromSwatch(
              accentColor: const Color(0xFF13B9FF),
            ),
          ),
          onGenerateRoute: (_) => TabRootPage.route(),
        ),
      ),
    );
  }
}
