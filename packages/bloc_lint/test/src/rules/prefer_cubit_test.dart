import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferCubit, () {
    lintTest(
      'lints when class extends Bloc',
      rule: PreferCubit.new,
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
      'lints when class extends HydratedBloc',
      rule: PreferCubit.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:hydrated_bloc/hydrated_bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends HydratedBloc<CounterEvent, int> {
      ^^^^^^^^^^^
  CounterBloc() : super(0);       
}
''',
    );

    lintTest(
      'lints when class extends MockBloc',
      rule: PreferCubit.new,
      path: 'app_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
      ^^^^^^^^^^^^^^^^
''',
    );

    lintTest(
      'does not lint when class extends Cubit',
      rule: PreferCubit.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint when class extends MockCubit',
      rule: PreferCubit.new,
      path: 'app_test.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCounterCubit extends MockCubit<int> implements CounterCubit {}
''',
    );
  });
}
