class SearchResult {
  final List<SearchResultItem> items;
  final bool isPopulated;
  final bool isEmpty;

  SearchResult({this.items, this.isPopulated, this.isEmpty});

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) =>
            SearchResultItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(
      items: items,
      isPopulated: items.isNotEmpty,
      isEmpty: items.isEmpty,
    );
  }

  @override
  String toString() =>
      'SearchResult { items: ${items.toString()}, isPopulated: $isPopulated, isEmpty: $isEmpty }';
}

class GithubUser {
  final String login;
  final String avatar_url;

  GithubUser({this.login, this.avatar_url});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatar_url: json['avatar_url'] as String,
    );
  }
}

class SearchResultItem {
  final String full_name;
  final String html_url;
  final GithubUser owner;

  SearchResultItem({this.full_name, this.html_url, this.owner});

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      full_name: json['full_name'] as String,
      html_url: json['html_url'] as String,
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
