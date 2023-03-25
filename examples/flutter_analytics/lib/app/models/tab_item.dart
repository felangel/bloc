import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';

class TabItem {
  const TabItem({
    required this.analytic,
    required this.widget,
    required this.tab,
  });

  final Analytic analytic;
  final Widget widget;
  final BottomNavigationBarItem tab;
}
