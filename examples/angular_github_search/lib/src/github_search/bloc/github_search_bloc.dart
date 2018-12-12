import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:bloc/bloc.dart';

import 'package:angular_github_search/src/github_service/github_service.dart';
import 'package:angular_github_search/src/github_search/bloc/bloc.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubService githubService;

  GithubSearchBloc(this.githubService);

  void onTextChanged(String text) {
    dispatch(TextChanged(text: text));
  }

  @override
  Stream<GithubSearchEvent> transform(Stream<GithubSearchEvent> events) {
    return (events as Observable).debounce(Duration(milliseconds: 300))
        as Stream<GithubSearchEvent>;
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition.toString());
  }

  @override
  GithubSearchState get initialState => GithubSearchState.initial();

  @override
  Stream<GithubSearchState> mapEventToState(
      GithubSearchState currentState, GithubSearchEvent event) async* {
    if (event is TextChanged) {
      final String term = event.text;
      if (term.isEmpty) {
        yield GithubSearchState.initial();
      } else {
        yield GithubSearchState.loading();

        try {
          final results = await githubService.search(term);
          yield GithubSearchState.success(results);
        } catch (_) {
          yield GithubSearchState.error();
        }
      }
    }
  }
}
