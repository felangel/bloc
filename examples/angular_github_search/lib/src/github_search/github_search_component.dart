import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:http/browser_client.dart';
import 'package:angular_bloc/angular_bloc.dart';

import 'package:angular_github_search/src/github_search/github_search.dart';
import 'package:angular_github_search/src/github_service/github_service.dart';

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
}
