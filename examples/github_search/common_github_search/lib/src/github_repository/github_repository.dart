import 'dart:async';

import 'package:common_github_search/src/github_repository/models/models.dart';
import 'package:common_github_search/src/github_repository/github_cache.dart';
import 'package:common_github_search/src/github_repository/github_client.dart';

class GithubRepository {
  final GithubCache cache;
  final GithubClient client;

  GithubRepository(this.cache, this.client);

  Future<SearchResult> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await client.search(term);

      cache.set(term, result);

      return result;
    }
  }
}
