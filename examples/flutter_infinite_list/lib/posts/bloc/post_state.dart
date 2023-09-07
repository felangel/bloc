part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

final class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.segments = const <PostSegment>[],
    this.hasReachedMax = false,
  });

  final PostStatus status;
  final List<PostSegment> segments;
  final bool hasReachedMax;

  PostState copyWith({
    PostStatus? status,
    List<PostSegment>? segments,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      segments: segments ?? this.segments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  int get countPosts =>
      segments.first.startIndex +
      segments.fold<int>(
        segments.first.startIndex,
        (count, nextSegment) => count + nextSegment.posts.length,
      );

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${segments.length} }''';
  }

  @override
  List<Object> get props => [status, segments, hasReachedMax];
}
