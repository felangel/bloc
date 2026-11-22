import 'package:common_github_search/common_github_search.dart';
import 'package:test/test.dart';

void main() {
  group('GithubUser', () {
    test('fromJson maps login and avatar_url', () {
      final user = GithubUser.fromJson({
        'login': 'octocat',
        'avatar_url': 'https://avatar',
      });

      expect(user.login, 'octocat');
      expect(user.avatarUrl, 'https://avatar');
    });
  });

  group('SearchResultItem', () {
    test('fromJson maps fields and nested owner', () {
      final item = SearchResultItem.fromJson({
        'full_name': 'a/a',
        'html_url': 'https://a',
        'owner': {'login': 'octocat', 'avatar_url': 'https://avatar'},
      });

      expect(item.fullName, 'a/a');
      expect(item.htmlUrl, 'https://a');
      expect(item.owner.login, 'octocat');
      expect(item.owner.avatarUrl, 'https://avatar');
    });
  });

  group('SearchResult', () {
    test('fromJson maps items and total_count', () {
      final result = SearchResult.fromJson({
        'total_count': 42,
        'items': [
          {
            'full_name': 'a/a',
            'html_url': 'https://a',
            'owner': {'login': 'octocat', 'avatar_url': 'https://avatar'},
          },
        ],
      });

      expect(result.totalCount, 42);
      expect(result.items.single.fullName, 'a/a');
    });

    test('fromJson defaults total_count to 0 when missing', () {
      final result = SearchResult.fromJson({'items': <dynamic>[]});

      expect(result.totalCount, 0);
      expect(result.items, isEmpty);
    });
  });

  group('SearchResultError', () {
    test('fromJson maps message', () {
      final error = SearchResultError.fromJson({'message': 'not found'});

      expect(error.message, 'not found');
    });
  });
}
