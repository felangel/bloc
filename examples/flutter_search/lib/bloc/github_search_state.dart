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

  factory GithubSearchState.success(List<SearchResultItem> searchResultItems) {
    return GithubSearchState(
      isLoading: true,
      isError: false,
      noTerm: false,
      result: SearchResult(
        isEmpty: searchResultItems.length <= 0,
        isPopulated: searchResultItems.length >= 0,
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

// abstract class PostState extends Equatable {
//   PostState([List props = const []]) : super(props);
// }

// class PostUninitialized extends PostState {
//   @override
//   String toString() => 'PostUninitialized';
// }

// class PostError extends PostState {
//   @override
//   String toString() => 'PostError';
// }

// class PostLoaded extends PostState {
//   final List<Post> posts;
//   // final bool hasReachedMax;

//   PostLoaded({
//     this.posts,
//     //this.hasReachedMax,
//   }) : super([posts]);

//   // PostLoaded copyWith({
//   //   List<Post> posts,
//   //   //bool hasReachedMax,
//   // }) {
//   //   return PostLoaded(
//   //     posts: posts ?? this.posts,
//   //   );
//   // }

//   @override
//   String toString() =>
//       'PostLoaded { posts: ${posts.length}}';
// }
