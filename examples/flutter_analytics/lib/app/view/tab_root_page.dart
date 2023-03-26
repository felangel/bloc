import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        items: [
          for (final tab in AppTab.values) tab.item.bottomNavigationBarItem,
        ],
      ),
      tabBuilder: (context, _) {
        return CupertinoTabView(
          navigatorObservers: [
            AppNavigatorObserver(
              context.read<AnalyticsRepository>(),
            ),
          ],
          onGenerateRoute: (_) => currentTab.item.route,
        );
      },
    );
  }
}
