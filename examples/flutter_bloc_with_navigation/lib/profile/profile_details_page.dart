import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/profile/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/widgets/page_content.dart';

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final ProfileBloc _profileBloc = BlocProvider.of<ProfileBloc>(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text('Profile details page'),
          ),
          body: PageContent(count: state.count),
          floatingActionButton: FloatingActionButton.extended(
            label: Text('Increment'),
            icon: Icon(Icons.add),
            onPressed: () => _profileBloc.add(const Increment()),
          ),
        );
      },
    );
  }
}
