import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'github-search-bar',
  templateUrl: 'github_search_bar_component.html',
)
class SearchBarComponent {
  @Input()
  GithubSearchBloc githubSearchBloc;

  void onTextChanged(String text) {
    githubSearchBloc.dispatch(TextChanged(text: text));
  }
}
