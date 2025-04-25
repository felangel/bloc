// ignore_for_file: no_adjacent_strings_in_list
import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/command_runner.dart';
import 'package:bloc_tools/src/version.dart';
import 'package:mason/mason.dart'
    show ExitCode, Logger, Progress, lightCyan, lightYellow;
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockProgress extends Mock implements Progress {}

class MockPubUpdater extends Mock implements PubUpdater {}

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
      '  lint   bloc lint [arguments]\n'
      '         Lint Dart source code.\n'
      '  new    bloc new <subcommand> [arguments]\n'
      '         Generate new bloc components.\n'
      '\n'
      'Run "bloc help <command>" for more information about a command.',
];

final updatePrompt = '''
+------------------------------------------------------------------------------------+
|                                                                                    |
|                    ${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}                     |
|  ${lightYellow.wrap('Changelog:')} ${lightCyan.wrap('https://github.com/felangel/bloc/releases/tag/$packageName-v$latestVersion')}  |
|                                                                                    |
+------------------------------------------------------------------------------------+
''';

const latestVersion = '0.0.0';

void main() {
  group('BlocToolsCommandRunner', () {
    late List<String> printLogs;
    late Logger logger;
    late PubUpdater pubUpdater;
    late BlocToolsCommandRunner commandRunner;

    void Function() overridePrint(void Function() fn) {
      return () {
        final spec = ZoneSpecification(
          print: (_, __, ___, String msg) {
            printLogs.add(msg);
          },
        );
        return Zone.current.fork(specification: spec).run<void>(fn);
      };
    }

    setUp(() {
      printLogs = [];
      logger = MockLogger();
      pubUpdater = MockPubUpdater();

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => packageVersion);
      when(() => pubUpdater.update(packageName: packageName)).thenAnswer(
        (_) =>
            Future.value(ProcessResult(0, ExitCode.success.code, null, null)),
      );

      commandRunner = BlocToolsCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
      );
    });

    test('can be instantiated without an explicit logger instance', () {
      final commandRunner = BlocToolsCommandRunner();
      expect(commandRunner, isNotNull);
    });

    group('run', () {
      test('prompts for update when newer version exists', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);

        when(() => logger.confirm(any())).thenReturn(false);

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.info(updatePrompt)).called(1);
        verify(() => logger.confirm('Would you like to update?')).called(1);
      });

      test('handles pub update errors gracefully', () async {
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenThrow(Exception('oops'));

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verifyNever(() => logger.info(updatePrompt));
      });

      test('updates on "y" response when newer version exists', () async {
        final progress = MockProgress();
        when(
          () => pubUpdater.getLatestVersion(any()),
        ).thenAnswer((_) async => latestVersion);

        when(() => logger.confirm(any())).thenReturn(true);
        when(() => logger.progress(any())).thenReturn(progress);

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('Updating to $latestVersion')).called(1);
      });

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

      test(
        'handles no command',
        overridePrint(() async {
          final result = await commandRunner.run([]);
          expect(printLogs, equals(expectedUsage));
          expect(result, equals(ExitCode.success.code));
        }),
      );

      group('--help', () {
        test(
          'outputs usage',
          overridePrint(() async {
            final result = await commandRunner.run(['--help']);
            expect(printLogs, equals(expectedUsage));
            expect(result, equals(ExitCode.success.code));

            printLogs.clear();

            final resultAbbr = await commandRunner.run(['-h']);
            expect(printLogs, equals(expectedUsage));
            expect(resultAbbr, equals(ExitCode.success.code));
          }),
        );
      });

      group('--version', () {
        test('outputs current version', () async {
          final result = await commandRunner.run(['--version']);
          expect(result, equals(ExitCode.success.code));
          verify(() => logger.info(packageVersion)).called(1);
        });
      });
    });
  });
}
