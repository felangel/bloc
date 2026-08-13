import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidMissingEventHandlers, () {
    lintTest(
      'lints when a sealed event subclass has no handler',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
final class Increment extends CounterEvent {}
final class Decrement extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
      ^^^^^^^^^^^
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
  }
}
''',
    );

    lintTest(
      'lints when an enum event has no handler',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
      ^^^^^^^^^^^
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'lints when a concrete event class has no handler',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
      ^^^^^^^^^^^
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not lint when every subclass has a handler',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
final class Increment extends CounterEvent {}
final class Decrement extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}
''',
    );

    lintTest(
      'does not lint when the event superclass is handled',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
final class Increment extends CounterEvent {}
final class Decrement extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) {});
  }
}
''',
    );

    lintTest(
      'does not lint when an enum event is handled',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterEvent>((event, emit) {});
  }
}
''',
    );

    lintTest(
      'does not lint when an ancestor handler covers a subclass',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
sealed class CounterWriteEvent extends CounterEvent {}
final class Increment extends CounterWriteEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterWriteEvent>((event, emit) {});
  }
}
''',
    );

    lintTest(
      'does not lint cubits',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint mock blocs',
      rule: AvoidMissingEventHandlers.new,
      path: 'app_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

enum CounterEvent { increment }

class _MockCounterBloc extends MockBloc<CounterEvent, int> {}
''',
    );

    lintTest(
      'does not lint abstract blocs',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment }

abstract class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not lint when the event type is not declared in the same file',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
  }
}
''',
    );

    lintTest(
      'lints hydrated blocs with missing handlers',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:hydrated_bloc/hydrated_bloc.dart';

enum CounterEvent { increment }

class CounterBloc extends HydratedBloc<CounterEvent, int> {
      ^^^^^^^^^^^
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not lint when handlers are registered outside the constructor',
      rule: AvoidMissingEventHandlers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    _registerHandlers();
  }

  void _registerHandlers() {
    on<CounterEvent>((event, emit) {});
  }
}
''',
    );
  });
}
