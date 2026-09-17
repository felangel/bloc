import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidMutableEvents, () {
    lintTest(
      'lints when an event has a non-final field',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  CounterIncrementPressed(this.count);

  int count;
  ^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when an event has a var field',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  var count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when an event has a late, non-final field',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  late int count;
  ^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when the base event class has a non-final field',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
abstract class CounterEvent {
  int count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when an event has a setter',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  set count(int value) {}
      ^^^^^
}
''',
    );

    lintTest(
      'does not lint when all event fields are final',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  const CounterIncrementPressed(this.count);

  final int count;
}
''',
    );

    lintTest(
      'does not lint late final event fields',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  late final int count;
}
''',
    );

    lintTest(
      'does not lint static event fields',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  static int instances = 0;
}
''',
    );

    lintTest(
      'does not lint const event fields',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  static const defaultCount = 0;
}
''',
    );

    lintTest(
      'does not lint getters on events',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  const CounterIncrementPressed(this.count);

  final int count;

  bool get isEven => count % 2 == 0;
}
''',
    );

    lintTest(
      'does not lint classes which are not events',
      rule: AvoidMutableEvents.new,
      path: 'counter.dart',
      content: '''
class Counter {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint state classes',
      rule: AvoidMutableEvents.new,
      path: 'counter_state.dart',
      content: '''
sealed class CounterState {}

final class CounterInitial extends CounterState {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint fields declared after the event class',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  const CounterIncrementPressed(this.count);

  final int count;
}

class Counter {
  int count = 0;
}
''',
    );

    lintTest(
      'does not lint when the mutable field is ignored',
      rule: AvoidMutableEvents.new,
      path: 'counter_event.dart',
      content: '''
sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {
  // ignore: avoid_mutable_events
  int count = 0;
}
''',
    );
  });
}
