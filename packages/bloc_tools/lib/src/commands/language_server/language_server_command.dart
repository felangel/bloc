import 'dart:async';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/lsp/language_server.dart';
import 'package:mason/mason.dart';

/// {@template language_server_command}
/// The `bloc language-server` command starts bloc's language server.
/// {@endtemplate}
class LanguageServerCommand extends Command<int> {
  /// {@macro language_server_command}
  LanguageServerCommand({LanguageServer Function()? languageServerBuilder})
    : _languageServerBuilder = languageServerBuilder ?? LanguageServer.new;

  @override
  String get summary => '$invocation\n$description';

  @override
  String get description => 'Start the bloc language server.';

  @override
  String get name => 'language-server';

  final LanguageServer Function() _languageServerBuilder;

  @override
  Future<int> run() async {
    final onExit = ReceivePort();
    final completer = Completer<void>();
    final subscription = onExit.listen(completer.complete);
    final isolate = await Isolate.spawn(
      (_) => _languageServerBuilder().listen(),
      null,
      onExit: onExit.sendPort,
    );
    isolate.addOnExitListener(onExit.sendPort);
    await completer.future;
    await subscription.cancel();
    return ExitCode.success.code;
  }
}
