import 'package:test/test.dart';
import 'package:todos_api/todos_api.dart';

class TestTodosApi extends TodosApi {
  TestTodosApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('TodosApi', () {
    test('can be constructed', () {
      expect(TestTodosApi.new, returnsNormally);
    });
  });
}
