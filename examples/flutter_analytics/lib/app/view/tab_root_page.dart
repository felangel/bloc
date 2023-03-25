import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabRootPage extends StatelessWidget {
  const TabRootPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'tab_root_page'),
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
                  Tab.values.elementAt(index),
                ),
              );
        },
        items: [for (final tab in Tab.values) tab.item.bottomNavigationBarItem],
      ),
      tabBuilder: (BuildContext context, _) {
        return CupertinoTabView(
          navigatorObservers: [
            AppNavigatorObserver(
              context.read<AnalyticsRepository>(),
            ),
          ],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => currentTab.item.widget,
            settings: RouteSettings(name: currentTab.item.routeName),
          ),
        );
      },
    );
  }
}
