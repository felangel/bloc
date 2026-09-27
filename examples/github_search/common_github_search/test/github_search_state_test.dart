import 'package:common_github_search/common_github_search.dart';
import 'package:test/test.dart';

const _owner = GithubUser(login: 'octocat', avatarUrl: 'https://avatar');
const _item = SearchResultItem(
  fullName: 'a/a',
  htmlUrl: 'https://a',
  owner: _owner,
);

void main() {
  group('SearchStateEmpty', () {
    test('supports value equality', () {
      expect(SearchStateEmpty(), SearchStateEmpty());
    });
  });

  group('SearchStateLoading', () {
    test('supports value equality', () {
      expect(SearchStateLoading(), SearchStateLoading());
    });
  });

  group('SearchStateSuccess', () {
    const state = SearchStateSuccess(
      items: [_item],
      searchTerm: 'flutter',
      page: 1,
      hasReachedMax: false,
      generation: 1,
    );

    test('supports value equality via props', () {
      expect(
        state,
        const SearchStateSuccess(
          items: [_item],
          searchTerm: 'flutter',
          page: 1,
          hasReachedMax: false,
          generation: 1,
        ),
      );
    });

    test('differs when any field differs', () {
      expect(
        state,
        isNot(
          const SearchStateSuccess(
            items: [_item],
            searchTerm: 'flutter',
            page: 2,
            hasReachedMax: false,
            generation: 1,
          ),
        ),
      );
    });

    test('toString summarises item count, page, max and generation', () {
      expect(
        state.toString(),
        'SearchStateSuccess { items: 1, page: 1, '
        'hasReachedMax: false, generation: 1 }',
      );
    });
  });

  group('SearchStateError', () {
    test('supports value equality via props', () {
      expect(
        const SearchStateError('boom'),
        const SearchStateError('boom'),
      );
      expect(
        const SearchStateError('boom'),
        isNot(const SearchStateError('bang')),
      );
    });
  });
}
