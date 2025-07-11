import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferContextExtensions, () {
    lintTest(
      'lints when using BlocProvider.of in a field assignment',
      rule: PreferContextExtensions.new,
      path: 'sample.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {

  late final a = BlocProvider.of<CounterCubit>(context);
                 ^^^^^^^^^^^^

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''',
    );

    lintTest(
      'lints when using BlocProvider.of in a getter',
      rule: PreferContextExtensions.new,
      path: 'sample.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {

  get cubit => BlocProvider.of<CounterCubit>(context);
               ^^^^^^^^^^^^
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''',
    );

    lintTest(
      'lints when using BlocProvider.of in a variable assignment',
      rule: PreferContextExtensions.new,
      path: 'sample.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {

  @override
  Widget build(BuildContext context) {
    final b = BlocProvider.of<CounterCubit>(context);
              ^^^^^^^^^^^^
    return Container();
  }
}
''',
    );

    lintTest(
      'lints when calling BlocProvider.of in a method',
      rule: PreferContextExtensions.new,
      path: 'sample.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CounterCubit>(context).increment();
    ^^^^^^^^^^^^
    return Container();
  }
}
''',
    );

    lintTest(
      'does not lint when using BlocProvider',
      rule: PreferContextExtensions.new,
      path: 'sample.dart',
      content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: Container(),
    );
  }
}
''',
    );
  });
}
