import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferFileNamingConventions, () {
    lintTest(
      'lints when CounterBloc is declared in main.dart',
      rule: PreferFileNamingConventions.new,
      path: 'main.dart',
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
      'lints when CounterBloc is declared in counter_cubit.dart',
      rule: PreferFileNamingConventions.new,
      path: 'counter_cubit.dart',
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
      'lints when CounterCubit is declared in main.dart',
      rule: PreferFileNamingConventions.new,
      path: 'main.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
      ^^^^^^^^^^^^
  CounterCubit() : super(0);       
}
''',
    );

    lintTest(
      'lints when CounterCubit is declared in counter_bloc.dart',
      rule: PreferFileNamingConventions.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
      ^^^^^^^^^^^^
  CounterCubit() : super(0);       
}
''',
    );

    lintTest(
      'does not lint when CounterBloc is declared in counter_bloc.dart',
      rule: PreferFileNamingConventions.new,
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
      'does not lint when CounterCubit is declared in counter_cubit.dart',
      rule: PreferFileNamingConventions.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint when extending MockBloc in tests',
      rule: PreferFileNamingConventions.new,
      path: 'counter_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
''',
    );

    lintTest(
      'does not lint when extending MockCubit in tests',
      rule: PreferFileNamingConventions.new,
      path: 'counter_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}
''',
    );
  });
}
