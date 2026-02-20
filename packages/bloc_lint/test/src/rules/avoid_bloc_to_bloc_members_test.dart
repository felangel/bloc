import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidBlocToBlocMembers, () {
    lintTest(
      'lints when bloc contains a bloc as a member',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  final CounterBloc counterBloc;
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  CounterSquaredBloc(required this.counterBloc) : super(0);
}
''',
    );

    lintTest(
      'lints when bloc contains a cubit as a member',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  final CounterCubit counterCubit;
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  CounterSquaredBloc(required this.counterCubit) : super(0);
}
''',
    );

    lintTest(
      'lints when bloc contains a bloc as a positional constructor parameter',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc(CounterBloc counterBloc) : super(counterBloc.state * counterBloc.state);
                     ^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains a cubit as a positional constructor parameter',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc(CounterCubit counterCubit) : super(counterCubit.state * counterCubit.state);
                     ^^^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains multiple positional bloc parameters',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterMultiplyBloc extends Bloc<CounterEvent, int> {
  CounterMultiplyBloc(
    CounterBloc counterBloc1,
    ^^^^^^^^^^^^^^^^^^^^^^^^
    CounterBloc? counterBloc2,
    ^^^^^^^^^^^^^^^^^^^^^^^^^
  ) : super(counterBloc1.state * counterBloc2.state);
}
''',
    );

    lintTest(
      'lints when bloc contains a an optional bloc named constructor parameter',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc({ CounterBloc? counterBloc }) : super(counterBloc.state * counterBloc.state);
                       ^^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains a an cubit parameter with a default',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc({ CounterCubit counterCubit = CounterCubit() }) : super(counterBloc.state * counterBloc.state);
                       ^^^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains required named bloc constructor parameter',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc({ required CounterBloc counterBloc }) : super(counterBloc.state * counterBloc.state);
                                ^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc contains multiple named bloc constructor parameters',
      rule: AvoidBlocToBlocMembers.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';


class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

class CounterSquaredBloc extends Bloc<CounterEvent, int> {
  CounterSquaredBloc({
    required CounterBloc counterBloc1,
             ^^^^^^^^^^^^^^^^^^^^^^^^
    CounterBloc? counterBloc2
    ^^^^^^^^^^^^^^^^^^^^^^^^^
  }) : super(counterBloc1.state * counterBloc2.state);
}
''',
    );
  });
}
