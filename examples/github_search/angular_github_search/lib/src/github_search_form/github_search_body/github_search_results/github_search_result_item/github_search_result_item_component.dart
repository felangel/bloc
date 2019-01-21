import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'github-search-result-item',
  templateUrl: 'github_search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  SearchResultItem item;
}
