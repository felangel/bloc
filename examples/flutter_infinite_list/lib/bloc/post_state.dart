import 'package:flutter_infinite_list/models/models.dart';

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
      'PostState { isInitializing: $isInitializing, posts: ${posts.length}, isError: $isError, hasReachedMax: $hasReachedMax }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostState &&
          runtimeType == other.runtimeType &&
          isInitializing == other.isInitializing &&
          posts == other.posts &&
          isError == other.isError &&
          hasReachedMax == other.hasReachedMax;

  @override
  int get hashCode =>
      isInitializing.hashCode ^
      posts.hashCode ^
      isError.hashCode ^
      hasReachedMax.hashCode;
}
