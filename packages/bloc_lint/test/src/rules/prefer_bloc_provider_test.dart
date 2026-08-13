import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferBlocProvider, () {
    lintTest(
      'lints when using Provider with a Bloc type',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CounterBloc>(
           ^^^^^^^^
      create: (_) => CounterBloc(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'lints when using Provider with a Cubit type',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<CounterCubit>(
           ^^^^^^^^
      create: (_) => CounterCubit(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'lints when using Provider with BlocBase',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<BlocBase>(
           ^^^^^^^^
      create: (_) => CounterCubit(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'lints when using Provider with a prefixed Bloc type',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:my_app/counter/counter.dart' as counter;
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<counter.CounterBloc>(
           ^^^^^^^^
      create: (_) => counter.CounterBloc(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'lints when using Provider with nested Bloc type arguments',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<Bloc<CounterEvent, int>>(
           ^^^^^^^^
      create: (_) => CounterBloc(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'lints when using Provider.value with a Bloc type',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Provider<CounterBloc>.value(
           ^^^^^^^^
      value: bloc,
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when using BlocProvider',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => CounterBloc(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when using Provider with a non-bloc type',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<WeatherRepository>(
      create: (_) => WeatherRepository(),
      child: const SizedBox(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when using Provider.of',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CounterBloc>(context);
    return const SizedBox();
  }
}
''',
    );

    lintTest(
      'does not lint when using Provider without a type argument',
      rule: PreferBlocProvider.new,
      path: 'my_widget.dart',
      content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => WeatherRepository(),
      child: const SizedBox(),
    );
  }
}
''',
    );
  });
}
