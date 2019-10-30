import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/home/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/widgets/page_content.dart';

class HomeDialog extends StatelessWidget {
  const HomeDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final HomeBloc _homeBloc = BlocProvider.of<HomeBloc>(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text('Home dialog'),
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
