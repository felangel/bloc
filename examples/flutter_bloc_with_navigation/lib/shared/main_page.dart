import 'package:flutter_bloc_with_navigation/home/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/profile/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();

  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
  };

  // ignore: close_sinks
  final HomeBloc _homeBloc = HomeBloc();
  // ignore: close_sinks
  final ProfileBloc _profileBloc = ProfileBloc();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ignore: close_sinks
    final AppBloc _appBloc = BlocProvider.of<AppBloc>(context);

    final List<Widget> pages = <Widget>[
      BlocProvider<HomeBloc>(
        builder: (_) => _homeBloc,
        child: Navigator(
          key: _navigatorKeys[0],
          initialRoute: AppRoute.root,
          onGenerateRoute: Router.generateHomeRoute,
          onUnknownRoute: Router.unknownRoute,
        ),
      ),
      BlocProvider(
        builder: (_) => _profileBloc,
        child: Navigator(
          key: _navigatorKeys[1],
          initialRoute: AppRoute.root,
          onGenerateRoute: Router.generateProfilesRoute,
          onUnknownRoute: Router.unknownRoute,
        ),
      ),
    ];

    return BlocListener<AppBloc, AppState>(
      bloc: _appBloc,
      listener: (BuildContext context, AppState state) {
        _pageController.animateToPage(
          state.activePageIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
      child: BlocBuilder<AppBloc, AppState>(
          bloc: _appBloc,
          builder: (BuildContext context, AppState appState) {
            // ? If receiving error 32000 when resuming app from background, it might be related to https://github.com/flutter/flutter/issues/40240
            // ? This might cause widgets to be disposed and state being lost when resuming app from background.
            return WillPopScope(
              onWillPop: () async {
                return !await _navigatorKeys[appState.activePageIndex]
                    .currentState
                    .maybePop();
              },
              child: Scaffold(
                body: PageView(
                  controller: _pageController,
                  children: pages,
                  onPageChanged: (int index) =>
                      _appBloc.add(PageChanged(newIndex: index)),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      title: Text('Home'),
                      icon: Icon(Icons.home),
                    ),
                    BottomNavigationBarItem(
                      title: Text('Profiles'),
                      icon: Icon(Icons.people),
                    ),
                  ],
                  currentIndex: appState.activePageIndex,
                  onTap: (int index) =>
                      _appBloc.add(PageChanged(newIndex: index)),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
