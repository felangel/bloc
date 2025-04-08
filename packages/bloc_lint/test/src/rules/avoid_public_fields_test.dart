import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidPublicFields, () {
    lintTest(
      'lints when bloc contains a public, mutable field',
      rule: AvoidPublicFields.new,
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
      'lints when cubit contains a public, mutable field',
      rule: AvoidPublicFields.new,
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
      'lints when bloc contains a public, mutable field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  int count = 0;
  ^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit contains a public, mutable field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  int count = 0;
  ^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, final field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  final int count;
  ^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit has a public, final field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(this.count) : super(0);

  final int count;
  ^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, final field with private type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
typedef _Count = int;
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  final _Count count;
  ^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit has a public, final field with private type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
typedef _Count = int;
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(this.count) : super(0);

  final _Count count;
  ^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, late field with private type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
typedef _Count = int;
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  late _Count count;
  ^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, late, final field with private type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
typedef _Count = int;
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  late final _Count count;
  ^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit has a public, late, final field with private type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
typedef _Count = int;
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(this.count) : super(0);

  late final _Count count;
  ^^^^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, late field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  late int count;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit has a public, late field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(this.count) : super(0);

  late int count;
  ^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when bloc has a public, late, final field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(this.count) : super(0);

  late final int count;
  ^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when cubit has a public, late, final field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(this.count) : super(0);

  late final int count;
  ^^^^^^^^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'does not lint when bloc contains a private, mutable field',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  var _count = 0;
}
''',
    );

    lintTest(
      'does not lint when cubit contains a private, mutable field',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  var _count = 0;
}
''',
    );

    lintTest(
      'does not lint when bloc contains a private, mutable field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  StreamSubscription? _subscription;
}
''',
    );

    lintTest(
      'does not lint when cubit contains a private, mutable field with type',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  StreamSubscription<int>? _subscription;
}
''',
    );

    lintTest(
      'does not lint when bloc has a private, late, final field',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  late final int _count;
}
''',
    );

    lintTest(
      'does not lint when cubit has a private, late, final field',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<CounterEvent, int> {
  CounterCubit() : super(0);

  late final int _count;
}
''',
    );

    lintTest(
      'does not lint when bloc has a public, static field',
      rule: AvoidPublicFields.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  static const count = 0;
}
''',
    );

    lintTest(
      'does not lint when cubit has a public, static field',
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  static const count = 0;
}
''',
    );

    lintTest(
      'does not lint when bloc has no fields',
      rule: AvoidPublicFields.new,
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
      rule: AvoidPublicFields.new,
      path: 'counter_cubit.dart',
      content: '''
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
''',
    );

    lintTest(
      'does not lint when external class contains public fields',
      rule: AvoidPublicFields.new,
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
