import 'package:common_github_search/common_github_search.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockGithubClient extends Mock implements GithubClient {}

class MockGithubCache extends Mock implements GithubCache {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SearchResult(items: [], totalCount: 0));
  });

  group('GithubRepository', () {
    late GithubClient client;
    late GithubCache cache;
    late GithubRepository repository;
    const result = SearchResult(items: [], totalCount: 0);

    setUp(() {
      client = MockGithubClient();
      cache = MockGithubCache();
      repository = GithubRepository(cache: cache, client: client);
    });

    test('cache miss calls the client and caches the result', () async {
      when(() => cache.get('flutter::1')).thenReturn(null);
      when(() => cache.set(any(), any())).thenReturn(null);
      when(
        () => client.search(
          any(),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => result);

      final actual = await repository.search('flutter');

      expect(actual, same(result));
      final captured = verify(
        () => client.search(
          'flutter',
          page: captureAny(named: 'page'),
          perPage: captureAny(named: 'perPage'),
        ),
      ).captured;
      expect(captured, [1, 30]);
      verify(() => cache.set('flutter::1', result)).called(1);
    });

    test(
      'cache hit returns cached result without calling the client',
      () async {
        when(() => cache.get('flutter::1')).thenReturn(result);

        final actual = await repository.search('flutter');

        expect(actual, same(result));
        verifyNever(
          () => client.search(
            any(),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
        verifyNever(() => cache.set(any(), any()));
      },
    );

    test('composite term::page key is used per page', () async {
      when(() => cache.get('flutter::2')).thenReturn(null);
      when(() => cache.set(any(), any())).thenReturn(null);
      when(
        () => client.search(
          any(),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => result);

      await repository.search('flutter', page: 2);

      verify(() => cache.get('flutter::2')).called(1);
      verify(
        () => client.search('flutter', page: 2, perPage: any(named: 'perPage')),
      ).called(1);
      verify(() => cache.set('flutter::2', result)).called(1);
    });

    test('forceRefresh bypasses the cache lookup and overwrites it', () async {
      when(() => cache.set(any(), any())).thenReturn(null);
      when(
        () => client.search(
          any(),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => result);

      final actual = await repository.search('flutter', forceRefresh: true);

      expect(actual, same(result));
      verifyNever(() => cache.get(any()));
      verify(
        () => client.search(
          'flutter',
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).called(1);
      verify(() => cache.set('flutter::1', result)).called(1);
    });

    test('dispose closes both the cache and the client', () {
      when(() => cache.close()).thenReturn(null);
      when(() => client.close()).thenReturn(null);

      repository.dispose();

      verify(() => cache.close()).called(1);
      verify(() => client.close()).called(1);
    });

    test('defaults to a real cache and client when none are provided', () {
      // Exercises the `?? GithubCache()` / `?? GithubClient()` fallbacks. No
      // request is made; the defaults are created and disposed immediately.
      GithubRepository().dispose();
    });
  });
}
