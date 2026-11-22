import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferMultiBlocListener, () {
    lintTest(
      'lints when a BlocListener is nested in the child of a BlocListener',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
         ^^^^^^^^^^^^
    listener: (context, state) {},
    child: BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'lints only the outermost BlocListener when several are nested',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
         ^^^^^^^^^^^^
    listener: (context, state) {},
    child: BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
      child: BlocListener<BlocC, BlocCState>(
        listener: (context, state) {},
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'lints when no type arguments are specified',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener(
         ^^^^^^^^^^^^
    listener: (context, state) {},
    child: BlocListener(
      listener: (context, state) {},
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'lints the outermost BlocListener of the nested chain '
      'rather than an unrelated ancestor',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) => showDialog(
      builder: (context) => BlocListener<BlocB, BlocBState>(
                            ^^^^^^^^^^^^
        listener: (context, state) {},
        child: BlocListener<BlocC, BlocCState>(
          listener: (context, state) {},
          child: const SizedBox(),
        ),
      ),
    ),
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint when nested deeper within other widgets',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) {},
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: BlocListener<BlocB, BlocBState>(
            listener: (context, state) {},
            child: const SizedBox(),
          ),
        ),
      ],
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a single BlocListener',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) {},
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint a MultiBlocListener',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return MultiBlocListener(
    listeners: [
      BlocListener<BlocA, BlocAState>(listener: (context, state) {}),
      BlocListener<BlocB, BlocBState>(listener: (context, state) {}),
    ],
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint sibling BlocListener widgets',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return Column(
    children: [
      BlocListener<BlocA, BlocAState>(
        listener: (context, state) {},
        child: const SizedBox(),
      ),
      BlocListener<BlocB, BlocBState>(
        listener: (context, state) {},
        child: const SizedBox(),
      ),
    ],
  );
}
''',
    );

    lintTest(
      'does not lint when the nested BlocListener is not a direct child',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) {},
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: BlocListener<BlocB, BlocBState>(
        listener: (context, state) {},
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint when a different widget is nested',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a BlocListener created inside a callback',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) {
      showDialog(
        context: context,
        builder: (context) => BlocListener<BlocB, BlocBState>(
          listener: (context, state) {},
          child: const SizedBox(),
        ),
      );
    },
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint when the nested BlocListener is ignored',
      rule: PreferMultiBlocListener.new,
      path: 'home_page.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  // ignore: prefer_multi_bloc_listener
  return BlocListener<BlocA, BlocAState>(
    listener: (context, state) {},
    child: BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
      child: const SizedBox(),
    ),
  );
}
''',
    );
  });
}
