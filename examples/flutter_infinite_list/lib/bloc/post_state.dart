import 'package:flutter_infinite_list/models/models.dart';

abstract class PostState {}

class PostUninitialized extends PostState {
  @override
  String toString() => 'PostUninitialized';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostUninitialized && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

class PostInitialized extends PostState {
  final List<Post> posts;
  final bool hasError;
  final bool hasReachedMax;

  PostInitialized({
    this.hasError,
    this.posts,
    this.hasReachedMax,
  });

  factory PostInitialized.success(List<Post> posts) {
    return PostInitialized(
      posts: posts,
      hasError: false,
      hasReachedMax: false,
    );
  }

  factory PostInitialized.failure() {
    return PostInitialized(
      posts: [],
      hasError: true,
      hasReachedMax: false,
    );
  }

  PostInitialized copyWith({
    List<Post> posts,
    bool hasError,
    bool hasReachedMax,
  }) {
    return PostInitialized(
      posts: posts ?? this.posts,
      hasError: hasError ?? this.hasError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'PostInitialized { posts: ${posts.length}, hasError: $hasError, hasReachedMax: $hasReachedMax }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostInitialized &&
          runtimeType == other.runtimeType &&
          posts == other.posts &&
          hasError == other.hasError &&
          hasReachedMax == other.hasReachedMax;

  @override
  int get hashCode =>
      posts.hashCode ^ hasError.hashCode ^ hasReachedMax.hashCode;
}
