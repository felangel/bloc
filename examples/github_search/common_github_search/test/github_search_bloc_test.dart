import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockGithubRepository extends Mock implements GithubRepository {}

// Shared fixture instances. SearchResultItem is not Equatable, so states
// compare items by identity — expected states must reuse the same instances.
const _owner = GithubUser(login: 'octocat', avatarUrl: 'https://avatar');
const _itemA = SearchResultItem(
  fullName: 'a/a',
  htmlUrl: 'https://a',
  owner: _owner,
);
const _itemB = SearchResultItem(
  fullName: 'b/b',
  htmlUrl: 'https://b',
  owner: _owner,
);
const _itemC = SearchResultItem(
  fullName: 'c/c',
  htmlUrl: 'https://c',
  owner: _owner,
);

void main() {
  late GithubRepository repository;

  setUp(() {
    repository = MockGithubRepository();
  });

  group('GithubSearchBloc', () {
    blocTest<GithubSearchBloc, GithubSearchState>(
      'debounced TextChanged emits [Loading, Success(page 1)]',
      setUp: () {
        when(() => repository.search('flutter')).thenAnswer(
          (_) async => const SearchResult(items: [_itemA], totalCount: 1),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const TextChanged(text: 'flutter')),
      wait: const Duration(milliseconds: 400),
      expect: () => <GithubSearchState>[
        SearchStateLoading(),
        const SearchStateSuccess(
          items: [_itemA],
          searchTerm: 'flutter',
          page: 1,
          hasReachedMax: true,
          generation: 1,
        ),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'NextPageRequested accumulates items and increments page',
      setUp: () {
        when(
          () => repository.search('flutter', page: 2),
        ).thenAnswer(
          (_) async => const SearchResult(items: [_itemB], totalCount: 100),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 5,
      ),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => const <GithubSearchState>[
        SearchStateSuccess(
          items: [_itemA, _itemB],
          searchTerm: 'flutter',
          page: 2,
          hasReachedMax: false,
          generation: 5,
        ),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'NextPageRequested is a no-op when hasReachedMax is true',
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: true,
        generation: 1,
      ),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => const <GithubSearchState>[],
      verify: (_) => verifyNever(
        () => repository.search(any(), page: any(named: 'page')),
      ),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'droppable: a second NextPageRequested in flight is dropped',
      setUp: () {
        when(() => repository.search('flutter', page: 2)).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 100),
            () => const SearchResult(items: [_itemB], totalCount: 100),
          ),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) => bloc
        ..add(const NextPageRequested())
        ..add(const NextPageRequested()),
      wait: const Duration(milliseconds: 300),
      expect: () => const <GithubSearchState>[
        SearchStateSuccess(
          items: [_itemA, _itemB],
          searchTerm: 'flutter',
          page: 2,
          hasReachedMax: false,
          generation: 0,
        ),
      ],
      verify: (_) =>
          verify(() => repository.search('flutter', page: 2)).called(1),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'Refreshed force-refreshes page 1 (forceRefresh: true)',
      setUp: () {
        when(
          () => repository.search('flutter', forceRefresh: true),
        ).thenAnswer(
          (_) async => const SearchResult(items: [_itemC], totalCount: 100),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA, _itemB],
        searchTerm: 'flutter',
        page: 2,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) => bloc.add(const Refreshed()),
      expect: () => const <GithubSearchState>[
        SearchStateSuccess(
          items: [_itemC],
          searchTerm: 'flutter',
          page: 1,
          hasReachedMax: false,
          generation: 1,
        ),
      ],
      verify: (_) => verify(
        () => repository.search('flutter', forceRefresh: true),
      ).called(1),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'Refreshed is a no-op when state is not SearchStateSuccess',
      build: () => GithubSearchBloc(githubRepository: repository),
      // Bloc starts in SearchStateEmpty; Refreshed must early-return safely.
      act: (bloc) => bloc.add(const Refreshed()),
      expect: () => const <GithubSearchState>[],
      verify: (_) => verifyNever(
        () => repository.search(
          any(),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'empty TextChanged emits [SearchStateEmpty] without hitting the repo',
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const TextChanged(text: '')),
      wait: const Duration(milliseconds: 400),
      expect: () => <GithubSearchState>[SearchStateEmpty()],
      verify: (_) => verifyNever(() => repository.search(any())),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'TextChanged with empty result marks hasReachedMax true',
      setUp: () {
        when(() => repository.search('flutter')).thenAnswer(
          (_) async => const SearchResult(items: [], totalCount: 0),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const TextChanged(text: 'flutter')),
      wait: const Duration(milliseconds: 400),
      expect: () => <GithubSearchState>[
        SearchStateLoading(),
        const SearchStateSuccess(
          items: [],
          searchTerm: 'flutter',
          page: 1,
          hasReachedMax: true,
          generation: 1,
        ),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'TextChanged maps SearchResultError to SearchStateError(message)',
      setUp: () {
        when(
          () => repository.search('flutter'),
        ).thenThrow(SearchResultError(message: 'rate limited'));
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const TextChanged(text: 'flutter')),
      wait: const Duration(milliseconds: 400),
      expect: () => <GithubSearchState>[
        SearchStateLoading(),
        const SearchStateError('rate limited'),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'TextChanged maps a generic error to the fallback message',
      setUp: () {
        when(() => repository.search('flutter')).thenThrow(Exception('boom'));
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const TextChanged(text: 'flutter')),
      wait: const Duration(milliseconds: 400),
      expect: () => <GithubSearchState>[
        SearchStateLoading(),
        const SearchStateError('something went wrong'),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'Refreshed emits SearchStateError when the repo throws',
      setUp: () {
        when(
          () => repository.search('flutter', forceRefresh: true),
        ).thenThrow(SearchResultError(message: 'refresh failed'));
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) => bloc.add(const Refreshed()),
      expect: () => const <GithubSearchState>[
        SearchStateError('refresh failed'),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'NextPageRequested is a no-op when state is not SearchStateSuccess',
      build: () => GithubSearchBloc(githubRepository: repository),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => const <GithubSearchState>[],
      verify: (_) => verifyNever(
        () => repository.search(any(), page: any(named: 'page')),
      ),
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'NextPageRequested emits SearchStateError when the repo throws',
      setUp: () {
        when(
          () => repository.search('flutter', page: 2),
        ).thenThrow(Exception('boom'));
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => const <GithubSearchState>[
        SearchStateError('something went wrong'),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'NextPageRequested with empty page marks hasReachedMax true',
      setUp: () {
        when(() => repository.search('flutter', page: 2)).thenAnswer(
          (_) async => const SearchResult(items: [], totalCount: 100),
        );
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) => bloc.add(const NextPageRequested()),
      expect: () => const <GithubSearchState>[
        SearchStateSuccess(
          items: [_itemA],
          searchTerm: 'flutter',
          page: 2,
          hasReachedMax: true,
          generation: 0,
        ),
      ],
    );

    blocTest<GithubSearchBloc, GithubSearchState>(
      'race guard: a slow next page resolving after a refresh is dropped',
      setUp: () {
        // Next page hangs until we complete it manually, AFTER the refresh.
        final pageCompleter = Completer<SearchResult>();
        when(
          () => repository.search('flutter', page: 2),
        ).thenAnswer((_) => pageCompleter.future);
        when(
          () => repository.search('flutter', forceRefresh: true),
        ).thenAnswer(
          (_) async => const SearchResult(items: [_itemC], totalCount: 100),
        );
        _pageCompleter = pageCompleter;
      },
      build: () => GithubSearchBloc(githubRepository: repository),
      // generation 0 matches the bloc's internal counter initial value.
      seed: () => const SearchStateSuccess(
        items: [_itemA],
        searchTerm: 'flutter',
        page: 1,
        hasReachedMax: false,
        generation: 0,
      ),
      act: (bloc) async {
        bloc.add(const NextPageRequested()); // captures generation 0, awaits
        await Future<void>.delayed(Duration.zero);
        bloc.add(const Refreshed()); // bumps generation to 1, emits page 1
        await Future<void>.delayed(const Duration(milliseconds: 50));
        _pageCompleter.complete(
          const SearchResult(items: [_itemB], totalCount: 100),
        ); // resolves late -> must be dropped, not merged
      },
      wait: const Duration(milliseconds: 100),
      // Only the refresh survives; the stale next page (would-be
      // [_itemA, _itemB]) is discarded because generation moved from 0 to 1.
      expect: () => const <GithubSearchState>[
        SearchStateSuccess(
          items: [_itemC],
          searchTerm: 'flutter',
          page: 1,
          hasReachedMax: false,
          generation: 1,
        ),
      ],
    );
  });
}

late Completer<SearchResult> _pageCompleter;
