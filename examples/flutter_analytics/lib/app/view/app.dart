import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    );
  }
}

class _AppBody extends StatefulWidget {
  const _AppBody();

  @override
  State<_AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<_AppBody> {
  static const _tabItems = [
    TabItem(
      analytic: Analytic('offer_tab_viewed'),
      widget: OfferTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.sell),
        label: 'Offers',
        backgroundColor: Colors.red,
      ),
    ),
    TabItem(
      analytic: Analytic('shopping_tab_viewed'),
      widget: ShoppingTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Shopping',
        backgroundColor: Colors.green,
      ),
    ),
    TabItem(
      analytic: Analytic('cart_tab_viewed'),
      widget: CartTab(),
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
        backgroundColor: Colors.purple,
      ),
    ),
  ];

  final _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      final analytic = _tabItems.elementAt(_tabController.index).analytic;
      context.read<AnalyticsRepository>().send(analytic);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        items: [for (final item in _tabItems) item.tab],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          navigatorObservers: [
            TabNavigatorObserver(
              tabAnalytic: _tabItems.elementAt(index).analytic,
              analyticsRepository: context.read<AnalyticsRepository>(),
            ),
          ],
          builder: (_) => _tabItems.elementAt(index).widget,
        );
      },
    );
  }
}
