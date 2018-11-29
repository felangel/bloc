import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/models/models.dart';

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final PostBloc _postBloc = PostBloc();
  final _scrollThreshold = 200.0;

  _MyHomePageState() {
    _scrollController.addListener(_onScroll);
    _postBloc.dispatch(Fetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _postBloc,
      builder: (BuildContext context, PostState state) {
        if (state.isInitializing) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.isError) {
          return Center(
            child: Text('failed to fetch posts'),
          );
        }
        if (state.posts.isEmpty) {
          return Center(
            child: Text('no posts'),
          );
        }
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return index >= state.posts.length
                ? _bottomLoader()
                : _postWidget(state.posts[index]);
          },
          itemCount:
              state.hasReachedMax ? state.posts.length : state.posts.length + 1,
          controller: _scrollController,
        );
      },
    );
  }

  @override
  void dispose() {
    _postBloc.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.dispatch(Fetch());
    }
  }

  Widget _postWidget(Post post) => ListTile(
        leading: Text(
          post.id.toString(),
          style: TextStyle(fontSize: 10.0),
        ),
        title: Text('${post.title}'),
        isThreeLine: true,
        subtitle: Text(post.body),
        dense: true,
      );

  Widget _bottomLoader() => Container(
        alignment: Alignment.center,
        child: Center(
          child: SizedBox(
            width: 33,
            height: 33,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
      );
}
