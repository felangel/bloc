import 'dart:async';
import 'dart:convert';

import 'package:common_github_search/common_github_search.dart';
import 'package:http/http.dart' as http;

class GithubClient {
  GithubClient({
    http.Client? httpClient,
    this.baseUrl = 'https://api.github.com/search/repositories?q=',
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Future<SearchResult> search(
    String term, {
    int page = 1,
    int perPage = 30,
  }) async {
    // ponytail: encode the term so an embedded `&` can't inject query params.
    final query = Uri.encodeQueryComponent(term);
    final response = await _httpClient.get(
      Uri.parse('$baseUrl$query&page=$page&per_page=$perPage'),
    );
    final results = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }

  void close() {
    _httpClient.close();
  }
}
