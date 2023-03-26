import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/cart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _analyticsRepository = const AnalyticsRepository();

  @override
  void initState() {
    super.initState();
    Bloc.observer = AppBlocObserver(_analyticsRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _analyticsRepository),
        RepositoryProvider(
          create: (_) => ShoppingRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppBloc(),
          ),
          BlocProvider(
            create: (context) => CartBloc(
              context.read<ShoppingRepository>(),
            )..add(
                const CartStarted(),
              ),
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
