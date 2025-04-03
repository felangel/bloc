import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidDependingOnFlutter, () {
    lintTest(
      'lints when bloc contains flutter import',
      rule: AvoidDependingOnFlutter.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'lints when cubit contains flutter import',
      rule: AvoidDependingOnFlutter.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class CounterCubit extends Cubit<int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not lint when no flutter import exists',
      rule: AvoidDependingOnFlutter.new,
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
      'does not lint when flutter import exists outside of bloc',
      rule: AvoidDependingOnFlutter.new,
      path: 'main.dart',
      content: '''
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
''',
    );
  });
}
