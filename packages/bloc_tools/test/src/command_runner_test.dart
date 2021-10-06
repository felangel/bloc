// ignore_for_file: no_adjacent_strings_in_list
import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/command_runner.dart';
import 'package:bloc_tools/src/version.dart';
import 'package:io/io.dart';
import 'package:mason/mason.dart' show Logger;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

const expectedUsage = [
  'Command Line Tools for the Bloc Library.\n'
      '\n'
      'Usage: bloc <command> [arguments]\n'
      '\n'
      'Global options:\n'
      '-h, --help       Print this usage information.\n'
      '    --version    Print the current version.\n'
      '\n'
      'Available commands:\n'
      '  help   Display help information for bloc.\n'
      '\n'
      'Run "bloc help <command>" for more information about a command.'
];

void main() {
  group('BlocToolsCommandRunner', () {
    late List<String> printLogs;
    late Logger logger;
    late BlocToolsCommandRunner commandRunner;

    void Function() overridePrint(void Function() fn) {
      return () {
        final spec = ZoneSpecification(print: (_, __, ___, String msg) {
          printLogs.add(msg);
        });
        return Zone.current.fork(specification: spec).run<void>(fn);
      };
    }

    setUp(() {
      printLogs = [];
      logger = MockLogger();
      commandRunner = BlocToolsCommandRunner(logger: logger);
    });

    test('can be instantiated without an explicit logger instance', () {
      final commandRunner = BlocToolsCommandRunner();
      expect(commandRunner, isNotNull);
    });

    group('run', () {
      test('handles FormatException', () async {
        const exception = FormatException('oops!');
        var isFirstInvocation = true;
        when(() => logger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(commandRunner.usage)).called(1);
      });

      test('handles UsageException', () async {
        final exception = UsageException('oops!', commandRunner.usage);
        var isFirstInvocation = true;
        when(() => logger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(commandRunner.usage)).called(1);
      });

      test('handles no command', overridePrint(() async {
        final result = await commandRunner.run([]);
        expect(printLogs, equals(expectedUsage));
        expect(result, equals(ExitCode.success.code));
      }));

      group('--help', () {
        test('outputs usage', overridePrint(() async {
          final result = await commandRunner.run(['--help']);
          expect(printLogs, equals(expectedUsage));
          expect(result, equals(ExitCode.success.code));

          printLogs.clear();

          final resultAbbr = await commandRunner.run(['-h']);
          expect(printLogs, equals(expectedUsage));
          expect(resultAbbr, equals(ExitCode.success.code));
        }));
      });

      group('--version', () {
        test('outputs current version', () async {
          final result = await commandRunner.run(['--version']);
          expect(result, equals(ExitCode.success.code));
          verify(() => logger.info('bloc_tools version: $packageVersion'));
        });
      });
    });
  });
}
