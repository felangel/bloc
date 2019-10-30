import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/home/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_with_navigation/shared/widgets/page_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ignore: close_sinks
    final HomeBloc _homeBloc = BlocProvider.of<HomeBloc>(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home page'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, AppRoute.dialog),
              ),
            ],
          ),
          body: PageContent(count: state.count),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FloatingActionButton.extended(
                label: Text('Increment'),
                icon: Icon(Icons.add),
                onPressed: () => _homeBloc.add(const Increment()),
              ),
              FloatingActionButton.extended(
                label: Text('Home details'),
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoute.details);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ? If you want the page to be disposed each time you navigate away from it then don't use AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;
}
