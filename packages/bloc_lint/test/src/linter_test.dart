import 'dart:io';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

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
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('analyzes an individual file', () {
        final file = File(path.join(tempDir.path, 'main.dart'))
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

      test('analyzes a nested directory file', () {
        final nested = Directory(path.join(tempDir.path, 'nested'))
          ..createSync(recursive: true);
        final main = File(path.join(nested.path, 'main.dart'))
          ..writeAsStringSync('void main() {}');
        final other = File(path.join(nested.path, 'other.dart'))
          ..writeAsStringSync('void other() {}');
        expect(
          linter.analyze(uri: nested.uri),
          equals({main.path: <Diagnostic>[], other.path: <Diagnostic>[]}),
        );
      });

      test('does nothing if file/directory does not exist', () {
        final invalid = File('invalid');
        expect(linter.analyze(uri: invalid.uri), isEmpty);
      });
    });
  });
}
