import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_infinite_list/posts/bloc/post_bloc.dart';
import 'package:flutter_infinite_list/posts/models/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

Uri _createPostUri({required int start}) {
  return Uri.https(
    'jsonplaceholder.typicode.com',
    '/posts',
    <String, String>{'_start': '$start', '_limit': '20'},
  );
}

void main() {
  group('PostBloc', () {
    final mockPosts = [
      const Post(id: 1, title: 'post title', body: 'post body')
    ];

    final extraMockPosts = [
      const Post(id: 2, title: 'post title', body: 'post body')
    ];

    late http.Client httpClient;

    setUp(() {
      httpClient = MockClient();
    });

    test('initial state is PostState()', () {
      expect(PostBloc(httpClient: httpClient).state, const PostState());
    });

    blocTest<PostBloc, PostState>(
      'emits nothing when posts has reached maximum amount',
      build: () => PostBloc(httpClient: httpClient),
      seed: () => const PostState().copyWith(hasReachedMax: true),
      act: (bloc) => bloc.add(PostFetched()),
      expect: () => <PostState>[],
    );

    blocTest<PostBloc, PostState>(
      'emits successful status when http fetches initial posts',
      build: () {
        when(() => httpClient.get(_createPostUri(start: 0)))
            .thenAnswer((_) async => http.Response(
                  '[{ "id": 1, "title": "post title", "body": "post body" }]',
                  200,
                ));
        return PostBloc(httpClient: httpClient);
      },
      wait: const Duration(milliseconds: 500),
      act: (bloc) => bloc.add(PostFetched()),
      expect: () => <PostState>[
        PostState(
            status: PostStatus.success, posts: mockPosts, hasReachedMax: false)
      ],
      verify: (_) =>
          verify(() => httpClient.get(_createPostUri(start: 0))).called(1),
    );

    blocTest<PostBloc, PostState>(
      'emits failure status when http fetches posts and throw exception',
      build: () {
        when(() => httpClient.get(_createPostUri(start: 0)))
            .thenAnswer((_) async => http.Response('', 500));
        return PostBloc(httpClient: httpClient);
      },
      wait: const Duration(milliseconds: 500),
      act: (bloc) => bloc.add(PostFetched()),
      expect: () =>
          <PostState>[const PostState().copyWith(status: PostStatus.failure)],
      verify: (_) =>
          verify(() => httpClient.get(_createPostUri(start: 0))).called(1),
    );

    blocTest<PostBloc, PostState>(
      'emits successful status and reaches max posts when '
      '0 additional posts are fetched',
      build: () {
        when(() => httpClient.get(_createPostUri(start: 1)))
            .thenAnswer((_) async => http.Response('[]', 200));
        return PostBloc(httpClient: httpClient);
      },
      seed: () => const PostState()
          .copyWith(status: PostStatus.success, posts: mockPosts),
      wait: const Duration(milliseconds: 500),
      act: (bloc) => bloc.add(PostFetched()),
      expect: () => <PostState>[
        PostState(
          status: PostStatus.success,
          posts: mockPosts,
          hasReachedMax: true,
        )
      ],
      verify: (_) =>
          verify(() => httpClient.get(_createPostUri(start: 1))).called(1),
    );

    blocTest<PostBloc, PostState>(
      'emits successful status and does not reach max posts'
      'when additional posts are fetched',
      build: () {
        when(() => httpClient.get(_createPostUri(start: 1)))
            .thenAnswer((_) async => http.Response(
                  '[{ "id": 2, "title": "post title", "body": "post body" }]',
                  200,
                ));
        return PostBloc(httpClient: httpClient);
      },
      seed: () => const PostState()
          .copyWith(status: PostStatus.success, posts: mockPosts),
      wait: const Duration(milliseconds: 500),
      act: (bloc) => bloc.add(PostFetched()),
      expect: () => <PostState>[
        PostState(
          status: PostStatus.success,
          posts: [...mockPosts, ...extraMockPosts],
          hasReachedMax: false,
        )
      ],
      verify: (_) =>
          verify(() => httpClient.get(_createPostUri(start: 1))).called(1),
    );
  });
}
