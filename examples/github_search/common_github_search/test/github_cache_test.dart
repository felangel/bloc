import 'package:common_github_search/common_github_search.dart';
import 'package:test/test.dart';

void main() {
  group('GithubCache', () {
    late GithubCache cache;
    const result = SearchResult(items: [], totalCount: 0);

    setUp(() {
      cache = GithubCache();
    });

    test('get returns null when the key is absent', () {
      expect(cache.get('flutter::1'), isNull);
    });

    test('set stores a result retrievable by get and reported by contains', () {
      cache.set('flutter::1', result);

      expect(cache.get('flutter::1'), same(result));
      expect(cache.contains('flutter::1'), isTrue);
      expect(cache.contains('flutter::2'), isFalse);
    });

    test('remove deletes a single entry', () {
      cache
        ..set('flutter::1', result)
        ..remove('flutter::1');

      expect(cache.contains('flutter::1'), isFalse);
    });

    test('close clears every entry', () {
      cache
        ..set('flutter::1', result)
        ..set('flutter::2', result)
        ..close();

      expect(cache.contains('flutter::1'), isFalse);
      expect(cache.contains('flutter::2'), isFalse);
    });
  });
}
