import 'dart:async';

import 'package:angular_github_search/src/github_service/models/models.dart';
import 'package:angular_github_search/src/github_service/github_cache.dart';
import 'package:angular_github_search/src/github_service/github_client.dart';

export './github_cache.dart';
export './github_client.dart';

class GithubService {
  final GithubCache cache;
  final GithubClient client;

  GithubService(this.cache, this.client);

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
