import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/view/cart_tab.dart';
import 'package:flutter_analytics/offer/view/offer_tab.dart';
import 'package:flutter_analytics/product_list/view/shopping_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension AppTabExtension on AppTab {
  Route<dynamic> get route {
    switch (this) {
      case AppTab.offers:
        return OfferTab.route();
      case AppTab.shopping:
        return ShoppingTab.route();
      case AppTab.cart:
        return CartTab.route();
    }
  }

  BottomNavigationBarItem get bottomNavigationBarItem {
    switch (this) {
      case AppTab.offers:
        return const BottomNavigationBarItem(
          icon: Icon(Icons.sell),
          label: 'Offers',
        );
      case AppTab.shopping:
        return const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Shopping',
        );
      case AppTab.cart:
        return const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        );
    }
  }
}

class TabRootPage extends StatelessWidget {
  const TabRootPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const AnalyticRouteSettings(
        screenView: ScreenView(routeName: 'tab_root_page'),
      ),
      builder: (_) => const TabRootPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select(
      (AppBloc bloc) => bloc.state.currentTab,
    );

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: currentTab.index,
        onTap: (index) {
          context.read<AppBloc>().add(
                AppTabPressed(
                  AppTab.values.elementAt(index),
                ),
              );
        },
        items: [for (final tab in AppTab.values) tab.bottomNavigationBarItem],
      ),
      tabBuilder: (context, _) {
        return CupertinoTabView(
          navigatorObservers: [
            AppNavigatorObserver(
              context.read<AnalyticsRepository>(),
            ),
          ],
          onGenerateRoute: (_) => currentTab.route,
        );
      },
    );
  }
}
