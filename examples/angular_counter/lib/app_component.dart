import 'package:angular_counter/src/counter_page/counter_page_component.dart';
import 'package:ngdart/angular.dart';

/// Top level application component.
@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [CounterPageComponent],
)
class AppComponent {}
