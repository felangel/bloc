import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

class GithubRepository {
  const GithubRepository(this.cache, this.client);

  final GithubCache cache;
  final GithubClient client;

  Future<SearchResult> search(String term) async {
    final cachedResult = cache.get(term);
    if (cachedResult != null) {
      return cachedResult;
    }
    final result = await client.search(term);
    cache.set(term, result);
    return result;
  }
}
