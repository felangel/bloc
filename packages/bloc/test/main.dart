import 'bloc_observer_test.dart' as bloc_observer_test;
import 'bloc_test.dart' as bloc_test;
import 'cubit_test.dart' as cubit_test;
import 'transition_test.dart' as transition_test;

void main() {
  bloc_test.main();
  bloc_observer_test.main();
  transition_test.main();
  cubit_test.main();
}
