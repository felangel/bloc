import 'dart:io';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'lint_test_helper.dart';

class _MockLintRule extends Mock implements LintRule {}

class _MockListener extends Mock implements Listener {}

class _FakeLintContext extends Fake implements LintContext {}

void main() {
  group(Linter, () {
    const name = 'prefer_bloc';

    late Listener listener;
    late LintRule rule;
    late Linter linter;

    setUpAll(() {
      registerFallbackValue(_FakeLintContext());
    });

    setUp(() {
      listener = _MockListener();
      rule = _MockLintRule();
      linter = const Linter();

      when(() => rule.create(any())).thenReturn(listener);
      when(() => rule.name).thenReturn(name);
    });

    group('analyze', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync();
        File(p.join(tempDir.path, 'pubspec.lock')).writeAsStringSync('''
packages:
  bloc:
    dependency: "direct main"
    description:
      name: bloc
      sha256: "52c10575f4445c61dd9e0cafcc6356fdd827c4c64dd7945ef3c4105f6b6ac189"
      url: "https://pub.dev"
    source: hosted
    version: "9.0.0"
sdks:
  dart: ">=3.6.0 <4.0.0"
''');
        File(
          p.join(tempDir.path, 'analysis_options.yaml'),
        ).writeAsStringSync('{}');
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('does nothing if file/directory does not exist', () {
        final invalid = File('invalid');
        expect(linter.analyze(uri: invalid.uri), isEmpty);
      });

      test('does nothing if pubspec.lock is malformed', () {
        File(p.join(tempDir.path, 'pubspec.lock')).writeAsStringSync('invalid');
        final file = File(p.join(tempDir.path, 'main.dart'))
          ..writeAsStringSync('''
void main() {
  print('hello world');
}
''');
        expect(
          linter.analyze(uri: file.uri),
          equals({file.path: <Diagnostic>[]}),
        );
      });

      test('analyzes an individual file', () {
        final file = File(p.join(tempDir.path, 'main.dart'))
          ..writeAsStringSync('''
void main() {
  print('hello world');
}
''');
        expect(
          linter.analyze(uri: file.uri),
          equals({file.path: <Diagnostic>[]}),
        );

        File(p.join(tempDir.path, 'analysis_options.yaml')).writeAsStringSync(
          '''
bloc:
  rules:
''',
        );

        expect(
          linter.analyze(uri: file.uri),
          equals({file.path: <Diagnostic>[]}),
        );
      });

      test('analyzes a nested directory file', () {
        final nested = Directory(p.join(tempDir.path, 'nested'))
          ..createSync(recursive: true);
        final main = File(p.join(nested.path, 'main.dart'))
          ..writeAsStringSync('void main() {}');
        final other = File(p.join(nested.path, 'other.dart'))
          ..writeAsStringSync('void other() {}');
        expect(
          linter.analyze(uri: nested.uri),
          equals({main.path: <Diagnostic>[], other.path: <Diagnostic>[]}),
        );
      });

      lintTest(
        'does not report when rule is ignored for file',
        rule: AvoidFlutterImports.new,
        path: 'counter_bloc.dart',
        content: '''
// ignore_for_file: ${AvoidFlutterImports.rule}
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
      );
    });

    lintTest(
      'does not report when ignore_for_file contains type=lint',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.dart',
      content: '''
// ignore_for_file: type=lint
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when //ignore: type=lint above',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

// ignore: type=lint
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when rule is ignored for line (above)',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';

// ignore: ${AvoidFlutterImports.rule}
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when //ignore: type=lint after',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart'; // ignore: type=lint

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when rule is ignored for line (after)',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart'; // ignore: ${AvoidFlutterImports.rule}

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when file is generated',
      rule: AvoidFlutterImports.new,
      path: 'counter_bloc.g.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );

    lintTest(
      'does not report when file is in a dot directory',
      rule: AvoidFlutterImports.new,
      path: '.fvm/counter_bloc.dart',
      content: '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
''',
    );
  });
}
