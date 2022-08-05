import 'package:angular/angular.dart';
import 'package:angular_github_search/src/github_search.dart';
import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-body',
  templateUrl: 'search_body_component.html',
  directives: [
    coreDirectives,
    SearchResultsComponent,
  ],
)
class SearchBodyComponent {
  @Input()
  late GithubSearchState state;

  bool get isEmpty => state is SearchStateEmpty;
  bool get isLoading => state is SearchStateLoading;
  bool get isSuccess => state is SearchStateSuccess;
  bool get isError => state is SearchStateError;

  List<SearchResultItem> get items =>
      isSuccess ? (state as SearchStateSuccess).items : [];

  String get error => isError ? (state as SearchStateError).error : '';
}
