import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferMultiBlocProvider, () {
    lintTest(
      'lints when a BlocProvider is nested in the child of a BlocProvider',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
         ^^^^^^^^^^^^
    create: (context) => BlocA(),
    child: BlocProvider<BlocB>(
      create: (context) => BlocB(),
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'lints only the outermost BlocProvider when several are nested',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
         ^^^^^^^^^^^^
    create: (context) => BlocA(),
    child: BlocProvider<BlocB>(
      create: (context) => BlocB(),
      child: BlocProvider<BlocC>(
        create: (context) => BlocC(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'lints when the value constructor is used',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build(BlocA blocA, BlocB blocB) {
  return BlocProvider<BlocA>.value(
         ^^^^^^^^^^^^
    value: blocA,
    child: BlocProvider<BlocB>.value(
      value: blocB,
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'lints when const BlocProvider is used in child',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build(BlocA blocA, BlocB blocB) {
  return BlocProvider<BlocA>.value(
         ^^^^^^^^^^^^
    value: blocA,
    child: const BlocProvider<BlocB>.value(
      value: blocB,
      child: SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a single BlocProvider',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint a MultiBlocProvider',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<BlocA>(create: (context) => BlocA()),
      BlocProvider<BlocB>(create: (context) => BlocB()),
    ],
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint when the nested BlocProvider is not a direct child',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: BlocProvider<BlocB>(
        create: (context) => BlocB(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint when a different widget is nested',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: RepositoryProvider<RepositoryA>(
      create: (context) => RepositoryA(),
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a BlocProvider created inside a callback',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: Builder(
      builder: (context) => BlocProvider<BlocB>(
        create: (context) => BlocB(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint when the nested BlocProvider is ignored',
      rule: PreferMultiBlocProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  // ignore: prefer_multi_bloc_provider
  return BlocProvider<BlocA>(
    create: (context) => BlocA(),
    child: BlocProvider<BlocB>(
      create: (context) => BlocB(),
      child: const SizedBox(),
    ),
  );
}
''',
    );
  });
}
