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
  const SearchStateSuccess({
    required this.items,
    required this.searchTerm,
    required this.page,
    required this.hasReachedMax,
    required this.generation,
  });

  final List<SearchResultItem> items;
  final String searchTerm;
  final int page;
  final bool hasReachedMax;

  /// Race-guard stamp bumped by every fresh search (TextChanged/Refreshed);
  /// see GithubSearchBloc — a stale in-flight next page is dropped unless the
  /// current success state still carries the same generation.
  final int generation;

  @override
  List<Object> get props => [
    items,
    searchTerm,
    page,
    hasReachedMax,
    generation,
  ];

  @override
  String toString() =>
      'SearchStateSuccess { items: ${items.length}, page: $page, '
      'hasReachedMax: $hasReachedMax, generation: $generation }';
}

final class SearchStateError extends GithubSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
