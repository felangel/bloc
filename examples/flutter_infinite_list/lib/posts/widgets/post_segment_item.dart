import 'package:flutter/material.dart';
import 'package:flutter_infinite_list/posts/models/post_segment.dart';
import 'package:flutter_infinite_list/posts/posts.dart';

class PostSegmentItem extends StatelessWidget {
  const PostSegmentItem({required this.segment, super.key});

  final PostSegment segment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final  children = segment.posts.map<Widget>((post)=>  ListTile(
        leading: Text('${post.id}', style: textTheme.bodySmall),
        title: Text(post.title),
        isThreeLine: true,
        subtitle: Text(post.body),
        dense: true,
      ));
      return Column(children: [...children]);
  }
}
