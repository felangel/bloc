```dart
import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

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
```
