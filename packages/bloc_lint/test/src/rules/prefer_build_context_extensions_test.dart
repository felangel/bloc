import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferBuildContextExtensions, () {
    group('BlocBuilder', () {
      lintTest(
        'lints when using BlocBuilder',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, int>(
           ^^^^^^^^^^^
      builder: (context, state) => Text('$state'),
    );
  }
}
''',
      );

      lintTest(
        'lints when using BlocBuilder (buildWhen)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, int>(
           ^^^^^^^^^^^
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => Text('$state'),
    );
  }
}
''',
      );
    });

    group('BlocSelector', () {
      lintTest(
        'lints when using BlocSelector',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterCubit, int, bool>(
           ^^^^^^^^^^^^
      selector: (state) => state.isEven,
      builder: (context, isEven) => Text('$isEven'),
    );
  }
}
''',
      );
    });

    group('BlocProvider', () {
      lintTest(
        'lints when using BlocProvider.of (assignment)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final count = BlocProvider.of<CounterCubit>(context).state;
                  ^^^^^^^^^^^^^^^
    return const Text('\$count');
  }
}
''',
      );

      lintTest(
        'lints when using BlocProvider.of (invocation)',
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
      onPressed: () => BlocProvider.of<CounterBloc>().add(CounterEvent.increment);
                       ^^^^^^^^^^^^^^^        
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
        'lints when using RepositoryProvider.of (assignment)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {    
    return BlocProvider(
      create: (context) => WeatherBloc(
        weatherRepository: RepositoryProvider.of<WeatherRepository>(context),
                           ^^^^^^^^^^^^^^^^^^^^^
      ),
      child: WeatherView(),
    );
  }
}
''',
      );

      lintTest(
        'lints when using RepositoryProvider.of (invocation)',
        rule: PreferBuildContextExtensions.new,
        path: 'my_button.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {        
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => RepositoryProvider.of<MyRepository>().add(),
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
      create: (_) => MyRepository(),
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
  final repository = MyRepository();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repository,
      child: const SizedBox(),
    );
  }  
}
''',
      );
    });
  });
}
