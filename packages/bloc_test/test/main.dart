import 'bloc_bloc_test_test.dart' as bloc_bloc_test_test;
import 'cubit_bloc_test_test.dart' as cubit_bloc_test_test;
import 'emits_exactly_test.dart' as emits_exactly_test;
import 'mock_bloc_test.dart' as mock_bloc_test;
import 'when_listen_test.dart' as when_listen_test;

void main() {
  when_listen_test.main();
  mock_bloc_test.main();
  cubit_bloc_test_test.main();
  emits_exactly_test.main();
  bloc_bloc_test_test.main();
}
