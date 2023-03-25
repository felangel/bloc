import 'dart:developer';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/models/tab_item.dart';
import 'package:flutter_analytics/app_bloc_observer.dart';
import 'package:flutter_analytics/root_navigator_observer.dart';
import 'package:flutter_analytics/tab_observer.dart';
import 'package:flutter_analytics/cart/view/cart_page.dart';
import 'package:flutter_analytics/offer/view/offer_page.dart';
import 'package:flutter_analytics/product/view/product_list_page.dart';
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
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.sell),
        label: 'Offers',
        backgroundColor: Colors.red,
      ),
      widget: OfferPage(),
    ),
    TabItem(
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Shopping',
        backgroundColor: Colors.green,
      ),
      widget: ProductListPage(),
    ),
    TabItem(
      tab: BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
        backgroundColor: Colors.purple,
      ),
      widget: CartPage(),
    ),
  ];

  final _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      log(
        _tabItems
            .elementAt(_tabController.index)
            .tab
            .label
            .toString()
            .toLowerCase(),
      );
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
              tabName: _tabItems.elementAt(index).tab.label,
              analyticsRepository: context.read<AnalyticsRepository>(),
            ),
          ],
          builder: (BuildContext context) => _tabItems.elementAt(index).widget,
        );
      },
    );
  }
}
