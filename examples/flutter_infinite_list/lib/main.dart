import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

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

  @override
  void dispose() {
    _postBloc.dispose();
    super.dispose();
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  String toString() => 'Post { id: $id }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;
}

abstract class PostEvent {}

class Fetch extends PostEvent {
  @override
  String toString() => 'Fetch';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fetch && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class PostState {
  final bool isInitializing;
  final List<Post> posts;
  final bool isError;
  final bool hasReachedMax;

  PostState({
    this.isError,
    this.isInitializing,
    this.posts,
    this.hasReachedMax,
  });

  factory PostState.initial() {
    return PostState(
      isInitializing: true,
      posts: [],
      isError: false,
      hasReachedMax: false,
    );
  }

  factory PostState.success(List<Post> posts) {
    return PostState(
      isInitializing: false,
      posts: posts,
      isError: false,
      hasReachedMax: false,
    );
  }

  factory PostState.failure() {
    return PostState(
      isInitializing: false,
      posts: [],
      isError: true,
      hasReachedMax: false,
    );
  }

  PostState copyWith({
    bool isInitializing,
    List<Post> posts,
    bool isError,
    bool hasReachedMax,
  }) {
    return PostState(
      isInitializing: isInitializing ?? this.isInitializing,
      posts: posts ?? this.posts,
      isError: isError ?? this.isError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'PostState { isInitializing: $isInitializing, posts: ${posts.length.toString()}, isError: $isError, hasReachedMax: $hasReachedMax }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostState &&
          runtimeType == other.runtimeType &&
          isInitializing == other.isInitializing &&
          posts == other.posts &&
          isError == other.isError;

  @override
  int get hashCode =>
      isInitializing.hashCode ^ posts.hashCode ^ isError.hashCode;
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client _httpClient = http.Client();

  @override
  Stream<PostEvent> transform(Stream<PostEvent> events) {
    return (events as Observable<PostEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => PostState.initial();

  @override
  Stream<PostState> mapEventToState(state, event) async* {
    if (event is Fetch && !state.hasReachedMax) {
      try {
        final posts = await _fetchPosts(state.posts.length, 20);
        if (posts.isEmpty) {
          yield state.copyWith(hasReachedMax: true);
        } else {
          yield PostState.success(state.posts + posts);
        }
      } catch (_) {
        yield PostState.failure();
      }
    }
  }

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await _httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}
