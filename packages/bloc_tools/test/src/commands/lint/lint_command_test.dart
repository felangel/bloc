import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_tools/src/commands/lint/lint_command.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockLinter extends Mock implements Linter {}

class _MockLogger extends Mock implements Logger {}

void main() {
  group('bloc lint', () {
    late Linter linter;
    late Logger logger;
    late LintCommand command;
    late CommandRunner<int> runner;

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    setUp(() {
      linter = _MockLinter();
      logger = _MockLogger();
      command = LintCommand(linter: linter, logger: logger);
      runner = _TestCommandRunner(command: command);
    });

    test('has correct metadata', () {
      expect(command.name, equals('lint'));
      expect(command.description, equals('Lint Dart source code.'));
      expect(
        command.summary,
        equals(
          ' lint [arguments]\n'
          'Lint Dart source code.',
        ),
      );
    });

    test('exits with usage error when no files were specified', () async {
      await expectLater(
        runner.run(['lint']),
        completion(equals(ExitCode.usage.code)),
      );
      verify(
        () => logger.info(any(that: contains('No files specified.'))),
      ).called(1);
    });

    test('exits with usage error when no diagnostics were reported', () async {
      when(() => linter.analyze(uri: any(named: 'uri'))).thenAnswer((_) => {});
      await expectLater(
        runner.run(['lint', 'main.dart']),
        completion(equals(ExitCode.usage.code)),
      );
      verify(
        () => logger.info(any(that: contains('No target files found.'))),
      ).called(1);
    });

    test('exits with success when no issues are detected', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File(path.join(tempDir.path, 'main.dart'))
        ..writeAsStringSync('void main() {}');
      when(() => linter.analyze(uri: any(named: 'uri'))).thenAnswer(
        (invocation) => {(invocation.namedArguments[#uri] as Uri).path: []},
      );
      await expectLater(
        runner.run(['lint', file.path]),
        completion(equals(ExitCode.success.code)),
      );
      verify(
        () => logger.info('''
0 issues found
Analyzed 1 file'''),
      ).called(1);
    });

    test('exits with error when multiple issues are detected', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File(path.join(tempDir.path, 'main.dart'))
        ..writeAsStringSync('void main() {}');
      when(() => linter.analyze(uri: any(named: 'uri'))).thenAnswer(
        (invocation) => {
          (invocation.namedArguments[#uri] as Uri).path: [
            const Diagnostic(
              range: Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 4),
              ),
              source: 'error source',
              message: 'error message',
              description: 'error description',
              code: 'error code',
              severity: Severity.error,
            ),
            const Diagnostic(
              range: Range(
                start: Position(line: 1, character: 0),
                end: Position(line: 1, character: 42),
              ),
              source: 'hint source',
              message: 'hint message',
              description: 'hint description',
              code: 'hint code',
              severity: Severity.hint,
            ),
            const Diagnostic(
              range: Range(
                start: Position(line: 2, character: 10),
                end: Position(line: 2, character: 20),
              ),
              source: 'info source',
              message: 'info message',
              description: 'info description',
              code: 'info code',
              severity: Severity.info,
            ),
            const Diagnostic(
              range: Range(
                start: Position(line: 3, character: 30),
                end: Position(line: 3, character: 78),
              ),
              source: 'warning source',
              message: 'warning message',
              description: 'warning description',
              code: 'warning code',
              severity: Severity.warning,
            ),
          ],
        },
      );
      await expectLater(runner.run(['lint', file.path]), completion(equals(1)));
      verify(
        () => logger.info('''
4 issues found
Analyzed 1 file'''),
      ).called(1);
    });
  });
}

class _TestCommandRunner extends CommandRunner<int> {
  _TestCommandRunner({required Command<int> command}) : super('', '') {
    addCommand(command);
  }
}
