import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/models/models.dart';

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
