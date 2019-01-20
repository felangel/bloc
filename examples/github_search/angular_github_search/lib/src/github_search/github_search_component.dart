import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:http/browser_client.dart';
import 'package:angular_bloc/angular_bloc.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search/github_search.dart';

@Component(
  selector: 'github-search',
  templateUrl: 'github_search_component.html',
  directives: [
    materialInputDirectives,
    coreDirectives,
    SearchResultsComponent,
  ],
  pipes: [BlocPipe],
)
class GithubSearchComponent {
  final GithubSearchBloc githubSearchBloc = GithubSearchBloc(
    GithubService(
      GithubCache(),
      GithubClient(BrowserClient()),
    ),
  );

  void onTextChanged(String text) {
    githubSearchBloc.dispatch(TextChanged(text: text));
  }
}
