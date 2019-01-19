class SearchResult {
  final List<SearchResultItem> items;

  SearchResult({this.items});

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) =>
            SearchResultItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
  }
}

class GithubUser {
  final String login;
  final String avatarUrl;

  GithubUser({this.login, this.avatarUrl});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

class SearchResultItem {
  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  SearchResultItem({this.fullName, this.htmlUrl, this.owner});

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }
}

class SearchResultError {
  final String message;

  SearchResultError({this.message});

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }
}
