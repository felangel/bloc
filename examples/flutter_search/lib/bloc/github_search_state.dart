import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);
}

class GithubSearchState extends SearchState {
  final bool isLoading;
  final bool isError;
  final bool noTerm;
  final SearchResult result;

  GithubSearchState({
    this.isLoading,
    this.isError,
    this.noTerm,
    this.result,
  }) : super([isLoading, isError, noTerm, result]);

  factory GithubSearchState.initial() {
    return GithubSearchState(
      isLoading: false,
      isError: false,
      noTerm: true,
      result: SearchResult(
        isEmpty: true,
        isPopulated: true,
        items: [],
      ),
    );
  }

  factory GithubSearchState.loading() {
    return GithubSearchState(
      isLoading: true,
      isError: false,
      noTerm: false,
      result: SearchResult(
        isEmpty: true,
        isPopulated: true,
        items: [],
      ),
    );
  }

  factory GithubSearchState.success(List<SearchResultItem> searchResultItems) {
    return new GithubSearchState(
      isLoading: false,
      isError: false,
      noTerm: false,
      result: SearchResult(
        isEmpty: searchResultItems.length == 0,
        isPopulated: searchResultItems.length != 0,
        items: searchResultItems,
      ),
    );
  }

  factory GithubSearchState.error() {
    return GithubSearchState(
      isLoading: false,
      isError: true,
      noTerm: false,
      result: SearchResult(
        isEmpty: true,
        isPopulated: true,
        items: [],
      ),
    );
  }

  @override
  String toString() =>
      'GithubSearchState { isLoading: $isLoading, isError: $isError, noTerm: $noTerm, result: ${result.toString()} }';
}
