import 'package:bloc_lint/src/rules/rules.dart';
import 'package:test/test.dart';

import '../lint_test_helper.dart';

void main() {
  group(PreferMultiRepositoryProvider, () {
    lintTest(
      'lints when a RepositoryProvider is nested '
      'in the child of a RepositoryProvider',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
         ^^^^^^^^^^^^^^^^^^
    create: (context) => RepositoryA(),
    child: RepositoryProvider<RepositoryB>(
      create: (context) => RepositoryB(),
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'lints only the outermost RepositoryProvider when several are nested',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
         ^^^^^^^^^^^^^^^^^^
    create: (context) => RepositoryA(),
    child: RepositoryProvider<RepositoryB>(
      create: (context) => RepositoryB(),
      child: RepositoryProvider<RepositoryC>(
        create: (context) => RepositoryC(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'lints when the value constructor is used',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build(RepositoryA repositoryA, RepositoryB repositoryB) {
  return RepositoryProvider<RepositoryA>.value(
         ^^^^^^^^^^^^^^^^^^
    value: repositoryA,
    child: RepositoryProvider<RepositoryB>.value(
      value: repositoryB,
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a single RepositoryProvider',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
    create: (context) => RepositoryA(),
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint a MultiRepositoryProvider',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<RepositoryA>(create: (context) => RepositoryA()),
      RepositoryProvider<RepositoryB>(create: (context) => RepositoryB()),
    ],
    child: const SizedBox(),
  );
}
''',
    );

    lintTest(
      'does not lint when the nested RepositoryProvider is not a direct child',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
    create: (context) => RepositoryA(),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: RepositoryProvider<RepositoryB>(
        create: (context) => RepositoryB(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint when a different widget is nested',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
    create: (context) => RepositoryA(),
    child: BlocProvider<BlocA>(
      create: (context) => BlocA(),
      child: const SizedBox(),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint a RepositoryProvider created inside a callback',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  return RepositoryProvider<RepositoryA>(
    create: (context) => RepositoryA(),
    child: Builder(
      builder: (context) => RepositoryProvider<RepositoryB>(
        create: (context) => RepositoryB(),
        child: const SizedBox(),
      ),
    ),
  );
}
''',
    );

    lintTest(
      'does not lint when the nested RepositoryProvider is ignored',
      rule: PreferMultiRepositoryProvider.new,
      path: 'app.dart',
      content: '''
import 'package:flutter_bloc/flutter_bloc.dart';

Widget build() {
  // ignore: prefer_multi_repository_provider
  return RepositoryProvider<RepositoryA>(
    create: (context) => RepositoryA(),
    child: RepositoryProvider<RepositoryB>(
      create: (context) => RepositoryB(),
      child: const SizedBox(),
    ),
  );
}
''',
    );
  });
}
