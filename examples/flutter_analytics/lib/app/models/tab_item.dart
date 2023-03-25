import 'package:flutter/cupertino.dart';

class TabItem {
  const TabItem({
    required this.widget,
    required this.tab,
  });

  final Widget widget;
  final BottomNavigationBarItem tab;
}
