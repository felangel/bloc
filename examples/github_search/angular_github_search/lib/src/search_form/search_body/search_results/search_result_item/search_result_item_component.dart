import 'package:angular/angular.dart';
import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-result-item',
  templateUrl: 'search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  late SearchResultItem item;
}
