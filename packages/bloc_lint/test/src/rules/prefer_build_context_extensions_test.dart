import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferBuildContextExtensions, () {
    group('BlocProvider', () {
      lintTest(
        'lints when using BlocProvider.of in an assignment',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterCubit>(context);
                 ^^^^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'lints when using BlocProvider.of in a callback',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {        
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        BlocProvider.of<CounterCubit>().add(CounterEvent.increment);
        ^^^^^^^^^^^^^^^
      },                       
    );
  }
}
''',
      );

      lintTest(
        'does not lint when using BlocProvider(create: ...)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const SizedBox(),
    );
  }
}
''',
      );

      lintTest(
        'does not lint when using BlocProvider.value',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {
  final bloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: const SizedBox(),
    );
  }

  @override
  void dispose() {
    bloc.close();
  }
}
''',
      );
    });

    group('RepositoryProvider', () {
      lintTest(
        'lints when using RepositoryProvider.of in an assignment',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<MyRepo>(context);
                 ^^^^^^^^^^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'lints when using RepositoryProvider.of in a callback',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {        
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => RepositoryProvider.of<MyRepo>().foo(),
                       ^^^^^^^^^^^^^^^^^^^^^                       
    );
  }
}
''',
      );

      lintTest(
        'does not lint when using RepositoryProvider(create: ...)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => MyRepo(),
      child: const SizedBox(),
    );
  }
}
''',
      );

      lintTest(
        'does not lint when using RepositoryProvider.value',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {
  final repo = MyRepo();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repo,
      child: const SizedBox(),
    );
  }

  @override
  void dispose() {
    repo.dispose();
  }
}
''',
      );
    });
  });
}
