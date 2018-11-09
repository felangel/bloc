import 'package:angular_github_search/src/github_service/models/models.dart';

class GithubSearchState {
  final bool isLoading;
  final bool isError;
  final bool noTerm;
  final SearchResult result;

  GithubSearchState({
    this.isLoading,
    this.isError,
    this.noTerm,
    this.result,
  });

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

  factory GithubSearchState.success(SearchResult result) {
    return GithubSearchState(
      isLoading: false,
      isError: false,
      noTerm: false,
      result: result,
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
