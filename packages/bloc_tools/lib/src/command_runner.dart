import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:bloc_tools/src/version.dart';
import 'package:io/io.dart';
import 'package:mason/mason.dart' show Logger;

/// {@template bloc_tools_command_runner}
/// A [CommandRunner] for the Bloc Tools CLI.
/// {@endtemplate}
class BlocToolsCommandRunner extends CommandRunner<int> {
  /// {@macro bloc_tools_command_runner}
  BlocToolsCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super('bloc', 'Command Line Tools for the Bloc Library.') {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final _argResults = parse(args);
      return await runCommand(_argResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      _logger.info('bloc_tools version: $packageVersion');
      return ExitCode.success.code;
    }
    return super.runCommand(topLevelResults);
  }
}
