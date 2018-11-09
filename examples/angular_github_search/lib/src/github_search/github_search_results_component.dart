import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular_github_search/src/github_search/github_search.dart';

@Component(
    selector: 'github-search-results',
    templateUrl: 'github_search_results_component.html',
    directives: [
      materialInputDirectives,
      coreDirectives,
      MaterialSpinnerComponent,
      MaterialIconComponent,
    ],
    pipes: [
      BlocPipe
    ])
class SearchResultsComponent {
  @Input()
  GithubSearchState state;
}
