import 'package:angular/angular.dart';
import 'package:angular_github_search/src/github_search.dart';
import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'my-app',
  template: '<search-form [githubRepository]="githubRepository"></search-form>',
  directives: [SearchFormComponent],
)
class AppComponent {
  final githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );
}
