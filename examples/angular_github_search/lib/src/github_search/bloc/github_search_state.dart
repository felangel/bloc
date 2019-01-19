import 'package:equatable/equatable.dart';

import 'package:angular_github_search/src/github_service/models/models.dart';

abstract class GithubSearchState extends Equatable {
  GithubSearchState([List props = const []]) : super(props);
}

class SearchStateEmpty extends GithubSearchState {
  @override
  String toString() => 'SearchStateEmpty';
}

class SearchStateLoading extends GithubSearchState {
  @override
  String toString() => 'SearchStateLoading';
}

class SearchStateSuccess extends GithubSearchState {
  final List<SearchResultItem> items;

  SearchStateSuccess(this.items) : super([items]);

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends GithubSearchState {
  @override
  String toString() => 'SearchStateError';
}
