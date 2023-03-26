import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/view/cart_tab.dart';
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_analytics/product_list/product_list.dart';

class TabItem {
  const TabItem({
    required this.route,
    required this.bottomNavigationBarItem,
  });

  final Route<void> route;
  final BottomNavigationBarItem bottomNavigationBarItem;
}

extension TabExtension on Tab {
  TabItem get item {
    switch (this) {
      case Tab.offers:
        return TabItem(
          route: OfferTab.route(),
          bottomNavigationBarItem: const BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Offers',
          ),
        );
      case Tab.shopping:
        return TabItem(
          route: ShoppingTab.route(),
          bottomNavigationBarItem: const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shopping',
          ),
        );
      case Tab.cart:
        return TabItem(
          route: CartTab.route(),
          bottomNavigationBarItem: const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        );
    }
  }
}
