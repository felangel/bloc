import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import '../bloc/bloc.dart';
import '../github_service/github_service.dart';
import '../models/models.dart';

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
      GithubSearchState state, GithubSearchEvent event) async* {
    if (event is TextChanged) {
      final String term = event.text;
      print("Search query : $term");
      if (term.isEmpty) {
        print("term is Empty");
        yield GithubSearchState.initial();
        print("Initial State $state");
      } else {
        print("term is not empty");
        yield GithubSearchState.loading();
        print("Loading State $state");

        try {
          final results = await githubService.search(term);
          print("Results fetched $results.items.toString()");
          List<SearchResultItem> searchResultItems = results.items;
          yield GithubSearchState.success(searchResultItems);
          print("Success state $state");
        } catch (_) {
          yield GithubSearchState.error();
        }
      }
    }
  }
}
