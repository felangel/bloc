import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/view/cart_tab.dart';
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_analytics/shopping/shopping.dart';

class TabItem {
  const TabItem({
    required this.routeName,
    required this.widget,
    required this.bottomNavigationBarItem,
  });

  final String routeName;
  final Widget widget;
  final BottomNavigationBarItem bottomNavigationBarItem;
}

extension TabExtension on Tab {
  TabItem get item {
    switch (this) {
      case Tab.offers:
        return const TabItem(
          routeName: 'offer_tab',
          widget: OfferTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Offers',
            backgroundColor: Colors.red,
          ),
        );
      case Tab.shopping:
        return const TabItem(
          routeName: 'shopping_tab',
          widget: ShoppingTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shopping',
            backgroundColor: Colors.green,
          ),
        );
      case Tab.cart:
        return const TabItem(
          routeName: 'cart_tab',
          widget: CartTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
            backgroundColor: Colors.purple,
          ),
        );
    }
  }
}
