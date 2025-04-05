import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_tools/src/commands/commands.dart';
import 'package:bloc_tools/src/version.dart';
import 'package:mason/mason.dart' show ExitCode, Logger, lightCyan, lightYellow;
import 'package:pub_updater/pub_updater.dart';

/// The package name.
const packageName = 'bloc_tools';

/// {@template bloc_tools_command_runner}
/// A [CommandRunner] for the Bloc Tools CLI.
/// {@endtemplate}
class BlocToolsCommandRunner extends CommandRunner<int> {
  /// {@macro bloc_tools_command_runner}
  BlocToolsCommandRunner({Logger? logger, PubUpdater? pubUpdater})
    : _logger = logger ?? Logger(),
      _pubUpdater = pubUpdater ?? PubUpdater(),
      super('bloc', 'Command Line Tools for the Bloc Library.') {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );
    addCommand(NewCommand(logger: _logger));
    addCommand(
      LintCommand(
        linter: const Linter(rules: recommendedRules),
        logger: _logger,
      ),
    );
  }

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);
      return await runCommand(argResults) ?? ExitCode.success.code;
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
    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    await _checkForUpdates();
    return exitCode;
  }

  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        _logger
          ..info('')
          ..info('''
+------------------------------------------------------------------------------------+
|                                                                                    |
|                    ${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}                     |
|  ${lightYellow.wrap('Changelog:')} ${lightCyan.wrap('https://github.com/felangel/bloc/releases/tag/$packageName-v$latestVersion')}  |
|                                                                                    |
+------------------------------------------------------------------------------------+
''');
        final confirm = _logger.confirm('Would you like to update?');
        if (confirm) {
          final progress = _logger.progress('Updating to $latestVersion');
          await _pubUpdater.update(packageName: packageName);
          progress.complete('Updated to $latestVersion');
        }
      }
    } catch (_) {}
  }
}
