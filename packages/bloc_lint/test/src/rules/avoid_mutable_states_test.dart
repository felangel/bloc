import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidMutableStates, () {
    lintTest(
      'lints when a state has a non-final field',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  CounterInitial(this.count);

  int count;
  ^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when a state has a var field',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  var count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when a state has a late, non-final field',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  late int count;
  ^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when the base state class has a non-final field',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
abstract class CounterState {
  int count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when a state has a setter',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  set count(int value) {}
      ^^^^^
}
''',
    );

    lintTest(
      'does not lint when all state fields are final',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  const CounterInitial(this.count);

  final int count;
}
''',
    );

    lintTest(
      'does not lint late final state fields',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  late final int count;
}
''',
    );

    lintTest(
      'does not lint static state fields',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  static int instances = 0;
}
''',
    );

    lintTest(
      'does not lint const state fields',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  static const defaultCount = 0;
}
''',
    );

    lintTest(
      'does not lint getters on states',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  const CounterInitial(this.count);

  final int count;

  bool get isEven => count % 2 == 0;
}
''',
    );

    lintTest(
      'does not lint classes which are not states',
      rule: AvoidMutableStates.new,
      path: 'counter.dart',
      content: '''
class Counter {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint event classes',
      rule: AvoidMutableStates.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint fields declared after the state class',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  const CounterInitial(this.count);

  final int count;
}

class Counter {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint when the mutable field is ignored',
      rule: AvoidMutableStates.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  // ignore: avoid_mutable_states
  int count = 0;
}
''',
    );
  });
}
