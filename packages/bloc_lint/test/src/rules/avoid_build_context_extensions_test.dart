import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(AvoidBuildContextExtensions, () {
    group('lints when', () {
      group('context.read', () {
        lintTest(
          'is used in a field assignment',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final a = context.read<CounterCubit>();
                 ^^^^^^^^^^^^

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''',
        );

        lintTest(
          'is used in a variable assignment',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();
                  ^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
        );

        lintTest(
          'is used in a method call',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CounterCubit>().increment();
    ^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
        );

        lintTest(
          'is declared with another variable on the same line',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final String someVar, counterBloc = context.read<CounterBloc>();
                                        ^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
        );

        lintTest(
          'is used with an inferred bloc type',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = context.read();
                                    ^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
        );
      });

      group('context.watch', () {
        lintTest(
          'is used in a getter',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  CounterCubit get cubit => context.watch<CounterCubit>();
                            ^^^^^^^^^^^^^

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
''',
        );

        lintTest(
          'is used in a variable assignment',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CounterCubit>().state;
                  ^^^^^^^^^^^^^
    return Text(count.toString());
  }
}
''',
        );

        lintTest(
          'is used in a widget',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('${context.watch<CounterCubit>().state}');
                   ^^^^^^^^^^^^^
  }
}
''',
        );

        lintTest(
          'is used in a ternary operator',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = true ? context.watch<CounterCubit>().state : null;
                         ^^^^^^^^^^^^^
    return Text(state.toString());
  }
}
''',
        );

        lintTest(
          'is used with Cubit type',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
                      ^^^^^^^^^^^^^
    return const SizedBox();
  }
}
''',
        );
      });

      group('context.select', () {
        lintTest(
          'is used in a variable assignment',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isEven = context.select<CounterCubit, int>((cubit) => cubit.state.isEven);
                   ^^^^^^^^^^^^^^
    return Text(isEven ? 'true' : 'false');
  }
}
''',
        );

        lintTest(
          'is used in a widget',
          rule: AvoidBuildContextExtensions.new,
          path: 'my_widget.dart',
          content: r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('${context.select<CounterCubit, int>((cubit) => cubit.state)}');
                   ^^^^^^^^^^^^^^
  }
}
''',
        );
      });
    });

    group('does not lint when', () {
      lintTest(
        'using BlocProvider.of',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<CounterCubit>(context);
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using BlocProvider(create: ...)',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterCubit(),
      child: const SizedBox(),
    );
  }
}
''',
      );

      lintTest(
        'using other method calls on context',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.size;
    final theme = context.theme;
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context in a string',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final message = 'context.read is allowed';
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context.read with non-bloc types',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyProvider>();
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context.watch with non-bloc types',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context.select with non-bloc types',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<MyProvider, String>((provider) => provider.value);
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context extensions with implicit dynamic types',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // These would be invalid Dart but should not trigger our rule
    context.read();
    context.watch();
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'using context.read with type inference for non-bloc types',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProvider provider = context.read();
    return const SizedBox();
  }
}
''',
      );

      lintTest(
        'the call target is not context (e.g. cascade)',
        rule: AvoidBuildContextExtensions.new,
        path: 'my_widget.dart',
        content: '''
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyThing {
  MyThing read<T>() => this;
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final thing = MyThing()..read<CounterCubit>();
    return const SizedBox();
  }
}
''',
      );
    });
  });
}
