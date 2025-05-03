import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferVoidPublicCubitMethods, () {
    lintTest(
      'does not lint when no public methods exist on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint when void public methods exist on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
''',
    );

    lintTest(
      'does not lint when Future<void> public methods exist on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  Future<void> increment() async => emit(state + 1);
}
''',
    );

    lintTest(
      'does not lint when FutureOr<void> public methods exist on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  FutureOr<void> increment() async => emit(state + 1);
}
''',
    );

    lintTest(
      'does not lint when void public getter exists on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void get foo => null;
}
''',
    );

    lintTest(
      'does not lint when explicit void public setter exists on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  String _tag = '';

  void set tag(String value) {
    tag = value;
  }
}
''',
    );

    lintTest(
      'does not lint when implicit void public setter exists on Cubit',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  String _tag = '';

  set tag(String value) {
    tag = value;
  }
}
''',
    );

    lintTest(
      'does not lint for overridden methods',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  
  @override
  String toString() => 'CounterCubit';
}
''',
    );

    lintTest(
      'does not lint when non-void public methods exist on other classes',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class Dash {
  bool get isCool => true;
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'lints when public getter exists on Cubit (bool)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  bool get isEven => state.isEven;
           ^^^^^^
}
''',
    );

    lintTest(
      'lints when public methods exist on Cubit (int)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int increment() {
      ^^^^^^^^^
    emit(state + 1);
    return state;
  }
}
''',
    );

    lintTest(
      'lints when public methods exist on Cubit (Future<int>)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  Future<int> increment() async {
              ^^^^^^^^^
    emit(state + 1);
    return state;
  }
}
''',
    );

    lintTest(
      'lints when public methods exist on Cubit (Future<Map<String, dynamic>>)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  Future<Map<String, dynamic>> increment() async {
                               ^^^^^^^^^
    emit(state + 1);
    return {'count': state};
  }
}
''',
    );

    lintTest(
      'lints when public methods exist on Cubit (explicit dynamic)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  dynamic increment() {
          ^^^^^^^^^
    emit(state + 1);
    return state;
  }
}
''',
    );

    lintTest(
      'lints when public methods exist on Cubit (implicit dynamic)',
      rule: PreferVoidPublicCubitMethods.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  increment() {
  ^^^^^^^^^
    emit(state + 1);
    return state;
  }
}
''',
    );
  });
}
