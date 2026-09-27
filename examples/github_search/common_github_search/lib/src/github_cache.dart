import 'package:common_github_search/common_github_search.dart';

class GithubCache {
  // ponytail: key is a composite 'term::page' string built by the repository;
  // the cache stays a plain String-keyed map (no per-page class needed).
  final _cache = <String, SearchResult>{};

  SearchResult? get(String term) => _cache[term];

  void set(String term, SearchResult result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);

  void close() {
    _cache.clear();
  }
}
