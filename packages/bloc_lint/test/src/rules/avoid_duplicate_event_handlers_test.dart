import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidDuplicateEventHandlers, () {
    lintTest(
      'lints when the same event handler is registered twice',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    on<CounterEvent>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'lints every duplicate when the same event handler '
      'is registered more than twice',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    on<CounterEvent>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^
    on<CounterEvent>((event, emit) => emit(state));
    ^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'lints when event handlers are registered outside of the constructor',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    _registerHandlers();
  }

  void _registerHandlers() {
    on<CounterEvent>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'lints when the duplicate event handler is registered '
      'with a different transformer',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    on<CounterEvent>(
    ^^^^^^^^^^^^^^^^
      (event, emit) => emit(state - 1),
      transformer: droppable(),
    );
  }
}
''',
    );

    lintTest(
      'lints when the duplicate event type is generic',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterEvent<T> {}
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent<String>>((event, emit) => emit(state + 1));
    on<CounterEvent<String>>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'lints when the bloc extends HydratedBloc',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:hydrated_bloc/hydrated_bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    on<CounterEvent>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'lints only within the bloc which registers the duplicate handler',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
  }
}

class OtherCounterBloc extends Bloc<CounterEvent, int> {
  OtherCounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    on<CounterEvent>((event, emit) => emit(state - 1));
    ^^^^^^^^^^^^^^^^
  }
}
''',
    );

    lintTest(
      'does not lint when all event handlers are unique',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
final class CounterIncrementPressed extends CounterEvent {}
final class CounterDecrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
    on<CounterDecrementPressed>((event, emit) => emit(state - 1));
  }
}
''',
    );

    lintTest(
      'does not lint when generic event types differ by type argument',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterEvent<T> {}
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent<String>>((event, emit) => emit(state + 1));
    on<CounterEvent<int>>((event, emit) => emit(state - 1));
  }
}
''',
    );

    lintTest(
      'does not lint when the same event is registered on separate blocs',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
  }
}

class OtherCounterBloc extends Bloc<CounterEvent, int> {
  OtherCounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
  }
}
''',
    );

    lintTest(
      'does not lint when the enclosing class is not a bloc',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter.dart',
      content: '''
class EventRegistry {
  EventRegistry() {
    on<String>((value) {});
    on<String>((value) {});
  }

  void on<T>(void Function(T) callback) {}
}
''',
    );

    lintTest(
      'does not lint handlers registered on another object',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventRegistry registry) : super(0) {
    registry.on<CounterEvent>((event) {});
    registry.on<CounterEvent>((event) {});
  }
}

class EventRegistry {
  void on<T>(void Function(T) callback) {}
}
''',
    );

    lintTest(
      'does not lint on clauses in try/catch blocks',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) {
      try {
        emit(state + 1);
      } on FormatException {
        addError(Exception('oops'));
      } on Exception {
        addError(Exception('oops'));
      }
    });
  }
}
''',
    );

    lintTest(
      'does not lint when the duplicate handler is ignored',
      rule: AvoidDuplicateEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) => emit(state + 1));
    // ignore: avoid_duplicate_event_handlers
    on<CounterEvent>((event, emit) => emit(state - 1));
  }
}
''',
    );
  });
}
