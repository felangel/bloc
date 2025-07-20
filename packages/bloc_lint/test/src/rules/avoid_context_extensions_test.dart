import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group('AvoidContextExtensions', () {
    group('context.read', () {
      lintTest(
        'lints when using context.read in a field assignment',
        rule: AvoidContextExtensions.new,
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
  late final a = context.read<CounterCubit>();
                         ^^^^

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.read in a variable assignment',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();
                          ^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.read in a method call',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CounterCubit>().increment();
            ^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when declared with another variable on the same line',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String someVar, counterBloc = context.read<CounterBloc>();
                                                ^^^^
    return Container();
  }
}
''',
      );
    });

    group('context.watch', () {
      lintTest(
        'lints when using context.watch in a getter',
        rule: AvoidContextExtensions.new,
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
  get cubit => context.watch<CounterCubit>();
                       ^^^^^

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.watch in a variable assignment',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CounterCubit>();
                          ^^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.watch in a widget tree',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Count: ${context.watch<CounterCubit>().state}');
                                  ^^^^^
  }
}
''',
      );

      lintTest(
        'lints when used inside a ternary operator',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = true ? context.watch<CounterCubit>() : null;
                                 ^^^^^
    return Container();
  }
}
''',
      );
    });

    group('context.select', () {
      lintTest(
        'lints when using context.select in a variable assignment',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.select<CounterCubit, int>((cubit) => cubit.state);
                      ^^^^^^

    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.select in a widget tree',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Count: ${context.select<CounterCubit, int>((cubit) => cubit.state)}');
                                  ^^^^^^
  }
}
''',
      );

      lintTest(
        'lints when using context.select in a method call',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final isPositive = context.select<CounterCubit, bool>((cubit) => cubit.state > 0);
                               ^^^^^^
    return Container();
  }
}
''',
      );
    });

    group('context.listen', () {
      lintTest(
        'lints when using context.listen in a method call',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    context.listen<CounterCubit, int>((previous, current) {
            ^^^^^^
      print('State changed from $previous to $current');
    });

    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.listen in a variable assignment',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final listener = context.listen<CounterCubit, int>((previous, current) {
                             ^^^^^^
      print('State changed from $previous to $current');
    });

    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.listen in a try-catch block',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.listen<CounterCubit, int>((previous, current) {
              ^^^^^^
        print('State changed from $previous to $current');
      });
    } catch (e) {
      // Handle error
    }

    return Container();
  }
}
''',
      );
    });

    group('negative tests - should not lint', () {
      lintTest(
        'does not lint when using BlocProvider.of',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<CounterCubit>(context);
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using other method calls on context',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.size;
    final theme = context.theme;
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context extensions on other variables',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final otherContext = context;
    final cubit = otherContext.read<CounterCubit>();
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using BlocProvider without .of',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

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

      lintTest(
        'does not lint when using context in a string',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final message = 'context.read is not allowed';
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context.read with non-bloc types',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MyProvider>();
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context.watch with non-bloc types',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MyProvider>();
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context.select with non-bloc types',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<MyProvider, String>((provider) => provider.value);
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context.listen with non-bloc types',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    context.listen<MyProvider>((previous, current) {
      print('Provider changed');
    });
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context extensions with types that do not end'
        ' with Bloc or Cubit',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<MyService>();
    final repository = context.watch<MyRepository>();
    final controller = context.select<MyController, bool>((c) => c.isActive);
    context.listen<MyNotifier>((previous, current) {});
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context extensions without type parameters',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    // These would be invalid Dart but should not trigger our rule
    context.read();
    context.watch();
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.read with type inference for Bloc',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = context.read();
                                            ^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.watch with type inference for Cubit',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final UserCubit userCubit = context.watch();
                                        ^^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using context.read with type inference for non-bloc'
        ' types',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProvider provider = context.read();
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.read with Bloc type',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = context.read<CounterBloc>();
                                ^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'lints when using context.watch with Cubit type',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sample extends StatelessWidget {
  const Sample({super.key});

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
                              ^^^^^
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when using a type alias for a Bloc',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef Counter = CounterBloc;

class Sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Current implementation does not resolve typedefs, so this should not lint.
    final Counter counter = context.read();
    return Container();
  }
}
''',
      );

      lintTest(
        'does not lint when the call target is not context (e.g. cascade)',
        rule: AvoidContextExtensions.new,
        path: 'sample.dart',
        content: '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyThing {
  MyThing read<T>() => this;
}

class Sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final thing = MyThing()..read<CounterCubit>();
    return Container();
  }
}
''',
      );
    });
  });
}
