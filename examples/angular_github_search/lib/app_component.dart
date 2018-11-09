import 'package:angular/angular.dart';

import 'package:angular_github_search/src/github_search/github_search_component.dart';

@Component(
  selector: 'my-app',
  template: '<github-search></github-search>',
  directives: [GithubSearchComponent],
)
class AppComponent {}
