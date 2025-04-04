import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidPublicBlocMethods, () {
    lintTest(
      'lints when bloc contains public methods',
      rule: AvoidPublicBlocMethods.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  void foo() { print ('foo'); }
       ^^^
}
''',
    );

    lintTest(
      'does not lint when no public methods exist',
      rule: AvoidPublicBlocMethods.new,
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
      'does not lint allowed methods',
      rule: AvoidPublicBlocMethods.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Future<void> close() => super.close();
}
''',
    );

    lintTest(
      'does not lint public method overrides',
      rule: AvoidPublicBlocMethods.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  bool operator==(bool value) => false;
}
''',
    );

    lintTest(
      'does not lint when public methods exist on Cubit',
      rule: AvoidPublicBlocMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  void increment() => emit(state + 1);
}
''',
    );
  });
}
