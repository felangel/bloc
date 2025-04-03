import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferBlocLint, () {
    lintTest(
      'lints when class extends Cubit',
      rule: PreferBlocLint.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
      ^^^^^^^^^^^^
  CounterCubit() : super(0);       
}
''',
    );

    lintTest(
      'lints when class extends HydratedCubit',
      rule: PreferBlocLint.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:hydrated_bloc/hydrated_bloc.dart';

class CounterCubit extends HydratedCubit<int> {
      ^^^^^^^^^^^^
  CounterCubit() : super(0);       
}
''',
    );

    lintTest(
      'lints when class extends MockCubit',
      rule: PreferBlocLint.new,
      path: 'app_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCounterCubit extends MockCubit<int> implements CounterCubit {}
      ^^^^^^^^^^^^^^^^^
''',
    );

    lintTest(
      'does not lint when class extends Bloc',
      rule: PreferBlocLint.new,
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
      'does not lint when class extends MockBloc',
      rule: PreferBlocLint.new,
      path: 'app_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
''',
    );
  });
}
