import 'package:common_github_search/common_github_search.dart';
import 'package:equatable/equatable.dart';

sealed class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends GithubSearchState {}

final class SearchStateLoading extends GithubSearchState {}

final class SearchStateSuccess extends GithubSearchState {
  const SearchStateSuccess(this.items);

  final List<SearchResultItem> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

final class SearchStateError extends GithubSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
