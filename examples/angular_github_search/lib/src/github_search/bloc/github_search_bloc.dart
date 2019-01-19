import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:bloc/bloc.dart';

import 'package:angular_github_search/src/github_service/github_service.dart';
import 'package:angular_github_search/src/github_search/bloc/bloc.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubService githubService;

  GithubSearchBloc(this.githubService);

  @override
  Stream<GithubSearchEvent> transform(Stream<GithubSearchEvent> events) {
    return (events as Observable<GithubSearchEvent>)
        .debounce(Duration(milliseconds: 300));
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition.toString());
  }

  @override
  GithubSearchState get initialState => SearchStateEmpty();

  @override
  Stream<GithubSearchState> mapEventToState(
    GithubSearchState currentState,
    GithubSearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String term = event.text;
      if (term.isEmpty) {
        yield SearchStateEmpty();
      } else {
        yield SearchStateLoading();

        try {
          final results = await githubService.search(term);
          yield SearchStateSuccess(results.items);
        } catch (_) {
          yield SearchStateError();
        }
      }
    }
  }
}
