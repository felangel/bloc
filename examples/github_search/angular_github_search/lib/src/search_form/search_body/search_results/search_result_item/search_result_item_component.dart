import 'package:common_github_search/common_github_search.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'search-result-item',
  templateUrl: 'search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  late SearchResultItem item;
}
