import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final List<SearchResultItem> items;
  final bool isPopulated;
  final bool isEmpty;

  SearchResult({this.items, this.isPopulated, this.isEmpty})
      : super([items, isPopulated, isEmpty]);

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

class GithubUser extends Equatable {
  final String login;
  final String avatar_url;

  GithubUser({this.login, this.avatar_url}) : super([login, avatar_url]);

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatar_url: json['avatar_url'] as String,
    );
  }

  @override
  String toString() => 'GithubUser { login: $login, avatar_url: $avatar_url }';
}

class SearchResultItem extends Equatable {
  final String full_name;
  final String html_url;
  final GithubUser owner;

  SearchResultItem({this.full_name, this.html_url, this.owner})
      : super([full_name, html_url, owner]);

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      full_name: json['full_name'] as String,
      html_url: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }

  @override
  String toString() =>
      'SearchResultItem { full_name: $full_name, html_url: $html_url, owner: ${owner.toString()}';
}

class SearchResultError extends Equatable {
  final String message;

  SearchResultError({this.message}) : super([message]);

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }
}
