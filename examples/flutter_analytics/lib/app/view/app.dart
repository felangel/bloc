import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/bloc/app_bloc.dart';
import 'package:flutter_analytics/app/models/tab_item.dart';
import 'package:flutter_analytics/cart/view/cart_tab.dart';
import 'package:flutter_analytics/logging/app_bloc_observer.dart';
import 'package:flutter_analytics/logging/root_navigator_observer.dart';
import 'package:flutter_analytics/logging/tab_observer.dart';
import 'package:flutter_analytics/offer/view/offer_page.dart';
import 'package:flutter_analytics/shopping/view/shopping_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return RepositoryProvider.value(
      value: _analyticsRepository,
      child: BlocProvider(
        create: (context) => AppBloc(),
        child: MaterialApp(
          navigatorObservers: [
            RootNavigatorObserver(_analyticsRepository),
          ],
          theme: ThemeData(
            appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
            colorScheme: ColorScheme.fromSwatch(
              accentColor: const Color(0xFF13B9FF),
            ),
          ),
          home: const _AppBody(),
        ),
      ),
    );
  }
}

class _AppBody extends StatelessWidget {
  const _AppBody();

  static const _tabItems = [
    TabItem(
      widget: OfferTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.sell),
        label: 'Offers',
        backgroundColor: Colors.red,
      ),
    ),
    TabItem(
      widget: ShoppingTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Shopping',
        backgroundColor: Colors.green,
      ),
    ),
    TabItem(
      widget: CartTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
        backgroundColor: Colors.purple,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select(
      (AppBloc bloc) => bloc.state.currentTab.index,
    );

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: (index) {
          context.read<AppBloc>().add(
                AppTabPressed(
                  Tab.values.elementAt(index),
                ),
              );
        },
        items: [for (final item in _tabItems) item.tab],
      ),
      tabBuilder: (BuildContext context, int index) {
        final tab = Tab.values.elementAt(index);
        final tabItem = _tabItems.elementAt(index);

        return CupertinoTabView(
          navigatorObservers: [
            TabNavigatorObserver(
              context.read<AnalyticsRepository>(),
            ),
          ],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => tabItem.widget,
            settings: RouteSettings(arguments: tab.routeAnalytic),
          ),
        );
      },
    );
  }
}
