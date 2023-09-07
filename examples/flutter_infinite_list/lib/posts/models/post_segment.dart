import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';

final class PostSegment extends Equatable {
  const PostSegment({
    required this.startIndex,
    required this.posts,
  });

  final int startIndex;
  // using posts.length for getting end index
  final List<Post> posts;

  @override
  List<Object> get props => [startIndex, posts];
}
