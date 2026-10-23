import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidReturningNewInstanceFromBlocProviderValue, () {
    lintTest(
      'lints when BlocProvider.value instantiates a Bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: CounterBloc(),
           ^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when BlocProvider.value instantiates a const Bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: const CounterBloc(),
           ^^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when BlocProvider.value instantiates a named constructor',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: CounterBloc.initial(),
           ^^^^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when BlocProvider.value instantiates a const named constructor',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: const CounterBloc.initial(),
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when generic BlocProvider<T>.value instantiates a Bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider<CounterBloc>.value(
    value: CounterBloc(),
           ^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when BlocProvider.value instantiates a Cubit',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: CounterCubit(),
           ^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when BlocProvider.value instantiates a generic Bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: GenericBloc<int>(),
           ^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when constructor has arguments',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: CounterBloc(initialCount: 0),
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when value argument is after other arguments',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    child: const MyWidget(),
    value: CounterBloc(),
           ^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'lints when instantiated without a trailing comma',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: CounterBloc())
           ^^^^^^^^^^^^^
}
''',
    );

    lintTest(
      'lints when instantiated with a library prefix',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs.dart' as blocs;

void build() {
  BlocProvider.value(
    value: blocs.CounterBloc(),
           ^^^^^^^^^^^^^^^^^^^
  );
}
''',
    );

    lintTest(
      'does not lint when value is a local variable reference',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(CounterBloc bloc) {
  BlocProvider.value(
    value: bloc,
  );
}
''',
    );

    lintTest(
      'does not lint when value is a private field',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget {
  late final CounterBloc _bloc;

  void build() {
    BlocProvider.value(
      value: _bloc,
    );
  }
}
''',
    );

    lintTest(
      'does not lint when value is widget.bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyState {
  final widget = (bloc: CounterBloc());

  void build() {
    BlocProvider.value(
      value: widget.bloc,
    );
  }
}
''',
    );

    lintTest(
      'does not lint when value has null assertion widget.bloc!',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyState {
  final widget = (bloc: CounterBloc());

  void build() {
    BlocProvider.value(
      value: widget.bloc!,
    );
  }
}
''',
    );

    lintTest(
      'does not lint when value is this.bloc',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget {
  late final CounterBloc bloc;

  void build() {
    BlocProvider.value(
      value: this.bloc,
    );
  }
}
''',
    );

    lintTest(
      'does not lint when value is context.read',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(BuildContext context) {
  BlocProvider.value(
    value: context.read<CounterBloc>(),
  );
}
''',
    );

    lintTest(
      'does not lint when value is context.watch',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(BuildContext context) {
  BlocProvider.value(
    value: context.watch<CounterBloc>(),
  );
}
''',
    );

    lintTest(
      'does not lint when value is BlocProvider.of(context)',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(BuildContext context) {
  BlocProvider.value(
    value: BlocProvider.of<CounterBloc>(context),
  );
}
''',
    );

    lintTest(
      'does not lint when value is BlocProvider.maybeOf(context)',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(BuildContext context) {
  BlocProvider.value(
    value: BlocProvider.maybeOf<CounterBloc>(context)!,
  );
}
''',
    );

    lintTest(
      'does not lint when value is from a service locator or factory function',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider.value(
    value: getIt<CounterBloc>(),
  );
}
''',
    );

    lintTest(
      'does not lint when using default BlocProvider constructor with create',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider(
    create: (_) => CounterBloc(),
  );
}
''',
    );

    lintTest(
      'does not lint when using generic default BlocProvider with create',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build() {
  BlocProvider<CounterBloc>(
    create: (_) => CounterBloc(),
  );
}
''',
    );

    lintTest(
      'does not lint when accessing list index',
      rule: AvoidReturningNewInstanceFromBlocProviderValue.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

void build(List<CounterBloc> blocs) {
  BlocProvider.value(
    value: blocs[0],
  );
}
''',
    );
  });
}
