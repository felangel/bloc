import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidFlutterImports, () {
    lintTest(
      'lints when bloc contains flutter import',
      rule: AvoidFlutterImports.new,
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
      rule: AvoidFlutterImports.new,
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
      rule: AvoidFlutterImports.new,
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
      rule: AvoidFlutterImports.new,
      path: 'main.dart',
      content: '''
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
''',
    );
  });
}
