import 'dart:async';
import 'dart:convert';

import '../models/models.dart';
import 'package:http/http.dart' as http;

class GithubClient {
  final String baseUrl;
  final http.Client client;

  GithubClient(
    http.Client client, {
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.client = client ?? http.Client();

  /// Search Github for repositories using the given term
  Future<SearchResult> search(String term) async {
    final response = await client.get(Uri.parse("$baseUrl$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
