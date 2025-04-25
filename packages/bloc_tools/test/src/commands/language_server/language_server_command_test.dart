import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/commands/language_server/language_server_command.dart';
import 'package:bloc_tools/src/lsp/language_server.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLanguageServer extends Mock implements LanguageServer {}

void main() {
  group('bloc language-server', () {
    late LanguageServer languageServer;
    late LanguageServerCommand command;
    late CommandRunner<int> runner;

    setUp(() {
      languageServer = _MockLanguageServer();
      command = LanguageServerCommand(
        languageServerBuilder: () => languageServer,
      );
      runner = _TestCommandRunner(command: command);
    });

    test('has correct metadata', () {
      expect(command.name, equals('language-server'));
      expect(command.description, equals('Start the bloc language server.'));
      expect(command.hidden, isTrue);
      expect(
        command.summary,
        equals(
          ' language-server [arguments]\n'
          'Start the bloc language server.',
        ),
      );
    });

    test('runs correctly', () async {
      when(() => languageServer.listen()).thenAnswer((_) async {});
      await expectLater(
        runner.run(['language-server']),
        completion(equals(ExitCode.success.code)),
      );
    });
  });
}

class _TestCommandRunner extends CommandRunner<int> {
  _TestCommandRunner({required Command<int> command}) : super('', '') {
    addCommand(command);
  }
}
