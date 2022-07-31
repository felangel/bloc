// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

extension on WidgetTester {
  Future<void> pumpPostsList(PostBloc postBloc) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: postBloc,
          child: PostsList(),
        ),
      ),
    );
  }
}

void main() {
  final mockPosts = List.generate(
    5,
    (i) => Post(id: i, title: 'post title', body: 'post body'),
  );

  late PostBloc postBloc;

  setUp(() {
    postBloc = MockPostBloc();
  });

  group('PostsList', () {
    testWidgets(
        'renders CircularProgressIndicator '
        'when post status is initial', (tester) async {
      when(() => postBloc.state).thenReturn(const PostState());
      await tester.pumpPostsList(postBloc);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'renders no posts text '
        'when post status is success but with 0 posts', (tester) async {
      when(() => postBloc.state).thenReturn(
        const PostState(status: PostStatus.success, hasReachedMax: true),
      );
      await tester.pumpPostsList(postBloc);
      expect(find.text('no posts'), findsOneWidget);
    });

    testWidgets(
        'renders 5 posts and a bottom loader when post max is not reached yet',
        (tester) async {
      when(() => postBloc.state).thenReturn(
        PostState(
          status: PostStatus.success,
          posts: mockPosts,
        ),
      );
      await tester.pumpPostsList(postBloc);
      expect(find.byType(PostListItem), findsNWidgets(5));
      expect(find.byType(BottomLoader), findsOneWidget);
    });

    testWidgets('does not render bottom loader when post max is reached',
        (tester) async {
      when(() => postBloc.state).thenReturn(
        PostState(
          status: PostStatus.success,
          posts: mockPosts,
          hasReachedMax: true,
        ),
      );
      await tester.pumpPostsList(postBloc);
      expect(find.byType(BottomLoader), findsNothing);
    });

    testWidgets('fetches more posts when scrolled to the bottom',
        (tester) async {
      when(() => postBloc.state).thenReturn(
        PostState(
          status: PostStatus.success,
          posts: List.generate(
            10,
            (i) => Post(id: i, title: 'post title', body: 'post body'),
          ),
        ),
      );
      await tester.pumpPostsList(postBloc);
      await tester.drag(find.byType(PostsList), const Offset(0, -500));
      verify(() => postBloc.add(PostFetched())).called(1);
    });
  });
}
