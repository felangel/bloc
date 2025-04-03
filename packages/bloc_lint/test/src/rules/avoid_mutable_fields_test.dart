import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidMutableFields, () {
    lintTest(
      'lints when bloc contains a public, mutable field',
      rule: AvoidMutableFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  var count = 0;
  ^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains a private, mutable field',
      rule: AvoidMutableFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  var _count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit contains a public, mutable field',
      rule: AvoidMutableFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  var count = 0;
  ^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit contains a private, mutable field',
      rule: AvoidMutableFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  var _count = 0;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'does not lint when bloc has no fields',
      rule: AvoidMutableFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not lint when cubit has no fields',
      rule: AvoidMutableFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint when other class contains mutable fields',
      rule: AvoidMutableFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class Other {
  var state = 0;
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );
  });
}
