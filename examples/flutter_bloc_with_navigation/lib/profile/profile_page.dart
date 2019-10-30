import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_navigation/profile/bloc/bloc.dart';
import 'package:flutter_bloc_with_navigation/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_with_navigation/shared/widgets/page_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ignore: close_sinks
    final ProfileBloc _profileBloc = BlocProvider.of<ProfileBloc>(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile page'),
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
                onPressed: () => _profileBloc.add(const Increment()),
              ),
              FloatingActionButton.extended(
                label: Text('Profile details'),
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

  @override
  bool get wantKeepAlive => true;
}
