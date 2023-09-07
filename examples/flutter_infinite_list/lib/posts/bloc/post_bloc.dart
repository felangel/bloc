import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:http/http.dart' as http;

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched);
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
    PostFetched event,
    Emitter<PostState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(
          state.copyWith(
            status: PostStatus.success,
            segments: [
              PostSegment(startIndex: posts.first.id, posts: posts),
            ],
            hasReachedMax: false,
          ),
        );
      }
      final posts = await _fetchPosts(state.countPosts);
      posts.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: PostStatus.success,
                segments: List.of(state.segments)
                  ..add(
                    PostSegment(
                      startIndex: state.countPosts,
                      posts: posts,
                    ),
                  ),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      state.copyWith(status: PostStatus.failure);
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((dynamic json) {
        final map = json as Map<String, dynamic>;
        return Post(
          id: map['id'] as int,
          title: map['title'] as String,
          body: map['body'] as String,
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}
