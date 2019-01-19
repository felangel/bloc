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
  final String avatarUrl;

  GithubUser({this.login, this.avatarUrl}) : super([login, avatarUrl]);

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }

  @override
  String toString() => 'GithubUser { login: $login, avatar_url: $avatarUrl }';
}

class SearchResultItem extends Equatable {
  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  SearchResultItem({this.fullName, this.htmlUrl, this.owner})
      : super([fullName, htmlUrl, owner]);

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }

  @override
  String toString() =>
      'SearchResultItem { full_name: $fullName, html_url: $htmlUrl, owner: ${owner.toString()}';
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
