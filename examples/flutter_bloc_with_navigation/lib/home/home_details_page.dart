import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/home/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/widgets/page_content.dart';

class HomeDetailsPage extends StatelessWidget {
  const HomeDetailsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final HomeBloc _homeBloc = BlocProvider.of<HomeBloc>(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text('Home details page'),
          ),
          body: PageContent(count: state.count),
          floatingActionButton: FloatingActionButton.extended(
            label: Text('Increment'),
            icon: Icon(Icons.add),
            onPressed: () => _homeBloc.add(const Increment()),
          ),
        );
      },
    );
  }
}
