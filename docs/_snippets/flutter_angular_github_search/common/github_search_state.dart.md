```dart
import 'package:equatable/equatable.dart';

import 'package:common_github_search/common_github_search.dart';

abstract class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends GithubSearchState {}

class SearchStateLoading extends GithubSearchState {}

class SearchStateSuccess extends GithubSearchState {
  final List<SearchResultItem> items;

  const SearchStateSuccess(this.items);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends GithubSearchState {
  final String error;

  const SearchStateError(this.error);

  @override
  List<Object> get props => [error];
}
```
