import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferEmitForEach, () {
    lintTest(
      'lints a manually managed subscription in a bloc',
      rule: PreferEmitForEach.new,
      path: 'counter_bloc.dart',
      content: '''
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(Stream<int> counts) : super(0) {
    _counts = counts.listen((n) => add(CountChanged(n)));
  }

  late final StreamSubscription<int> _counts;
             ^^^^^^^^^^^^^^^^^^

  @override
  Future<void> close() async {
    await _counts.cancel();
    return super.close();
  }
}
''',
    );

    lintTest(
      'lints a nullable, prefixed subscription in a generic bloc',
      rule: PreferEmitForEach.new,
      path: 'items_bloc.dart',
      content: '''
class Items<T> extends hydrated.HydratedBloc<Event, T> {
  async.StreamSubscription<List<T>>? _items;
        ^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints an unparameterized subscription',
      rule: PreferEmitForEach.new,
      path: 'items_bloc.dart',
      content: '''
class ItemsBloc extends ReplayBloc<Event, State> {
  @override
  late StreamSubscription subscription;
       ^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'allows emitter-managed streams and unrelated field types',
      rule: PreferEmitForEach.new,
      path: 'items_bloc.dart',
      content: '''
class ItemsBloc extends Bloc<Event, int> {
  ItemsBloc(Stream<int> values) : super(0) {
    on<Started>((event, emit) => emit.forEach(values, onData: (n) => n));
  }

  static StreamSubscription<int>? shared;
  late List<StreamSubscription<int>> subscriptions;
  late StreamSubscription<int> Function() createSubscription;
  late int StreamSubscription;
}
''',
    );

    lintTest(
      'ignores cubits, mocks and declarations outside a bloc',
      rule: PreferEmitForEach.new,
      path: 'counter_bloc.dart',
      content: '''
class CounterBloc extends Bloc<Event, int> {}
mixin Subscriptions { late StreamSubscription<int> sub; }
class CounterCubit extends Cubit<int> { late StreamSubscription<int> sub; }
class FakeCounter extends MockBloc<Event, int> { late StreamSubscription<int> sub; }
abstract class ContractBloc extends Bloc<Event, int> {
  abstract StreamSubscription<int> subscription;
  external StreamSubscription<int> externalSubscription;
}
class Client { late StreamSubscription<int> sub; }
StreamSubscription<int>? subscription;
''',
    );
  });
}
