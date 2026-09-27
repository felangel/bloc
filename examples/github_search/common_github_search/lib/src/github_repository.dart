import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

class GithubRepository {
  GithubRepository({GithubCache? cache, GithubClient? client})
    : _cache = cache ?? GithubCache(),
      _client = client ?? GithubClient();

  final GithubCache _cache;
  final GithubClient _client;

  Future<SearchResult> search(
    String term, {
    int page = 1,
    int perPage = 30,
    bool forceRefresh = false,
  }) async {
    // ponytail: composite term+page cache key so pages cache independently.
    final cacheKey = '$term::$page';
    if (!forceRefresh) {
      final cachedResult = _cache.get(cacheKey);
      if (cachedResult != null) {
        return cachedResult;
      }
    }
    final result = await _client.search(term, page: page, perPage: perPage);
    // Overwrite so a forced refresh never leaves stale cached data behind.
    _cache.set(cacheKey, result);
    return result;
  }

  void dispose() {
    _cache.close();
    _client.close();
  }
}
