import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidReturningExistingInstanceFromBlocProviderCreate, () {
    lintTest(
      'lints when returning an existing instance',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final bloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc,
                     ^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning an existing instance from the widget',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => widget.bloc,
                     ^^^^^^^^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning an existing instance without a trailing comma',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => bloc);
                                       ^^^^
  }
}
''',
    );

    lintTest(
      'lints when returning an existing instance from a generic BlocProvider',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (_) => bloc,
                     ^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when create is preceded by other arguments',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: const Key('counter'),
      create: (_) => bloc,
                     ^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning the result of context.read',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<CounterBloc>(),
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning the result of watch on the create parameter',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ctx.watch<CounterBloc>(),
                       ^^^^^^^^^^^^^^^^^^^^^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning the result of BlocProvider.of',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocProvider.of<CounterBloc>(context),
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'lints when returning an existing instance from a block body',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = context.read<CounterBloc>();
        return bloc;
               ^^^^
      },
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when creating a new instance',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when creating a new const instance',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => const CounterBloc(),
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when using a named constructor',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc.initial(),
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when calling a factory function',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

CounterBloc createCounterBloc() => CounterBloc();

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCounterBloc(),
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when resolving via a service locator',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CounterBloc>(),
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when creating a new instance in a block body',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = context.read<CounterRepository>();
        return CounterBloc(repository: repository);
      },
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when create is a tear-off',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

CounterBloc createCounterBloc(BuildContext context) => CounterBloc();

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: createCounterBloc,
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when using BlocProvider.value',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({required this.bloc, super.key});

  final CounterBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: const CounterView(),
    );
  }
}
''',
    );

    lintTest(
      'does not lint when the provider is not a BlocProvider',
      rule: AvoidReturningExistingInstanceFromBlocProviderCreate.new,
      path: 'counter_page.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({required this.repository, super.key});

  final CounterRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => repository,
      child: const CounterView(),
    );
  }
}
''',
    );
  });
}
