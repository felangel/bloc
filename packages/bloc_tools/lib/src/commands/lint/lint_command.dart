import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:bloc_lint/bloc_lint.dart';
import 'package:mason/mason.dart';

/// {@template new_command}
/// The `bloc lint` command lints Dart source code.
/// {@endtemplate}
class LintCommand extends Command<int> {
  /// {@macro new_command}
  LintCommand({required Linter linter, required Logger logger})
    : _linter = linter,
      _logger = logger;

  @override
  String get summary => '$invocation\n$description';

  @override
  String get description => 'Lint Dart source code.';

  @override
  String get name => 'lint';

  final Linter _linter;
  final Logger _logger;

  @override
  int run() {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      _logger.info('''
${styleBold.wrap(lightRed.wrap('error'))}: No files specified.
Usage: bloc lint [OPTIONS] [files]...''');
      return ExitCode.usage.code;
    }

    final uris = rest.map(Uri.tryParse).whereType<Uri>();
    final diagnostics = uris
        .map((uri) => _linter.analyze(uri: uri))
        .fold(<String, List<Diagnostic>>{}, (prev, curr) => {...prev, ...curr});

    if (diagnostics.isEmpty) {
      _logger.info(
        '${styleBold.wrap(lightRed.wrap('error'))}: No target files found.',
      );
      return ExitCode.usage.code;
    }

    var issueCount = 0;
    var fileCount = 0;
    for (final entry in diagnostics.entries) {
      for (final diagnostic in entry.value) {
        final document = TextDocument(
          uri: Uri.parse(entry.key),
          content: File(entry.key).readAsStringSync(),
        );
        _logger.info(diagnostic.prettify(entry.key, document));
        issueCount++;
      }
      fileCount++;
    }
    _logger.info('''
$issueCount ${issueCount == 1 ? 'issue' : 'issues'} found
Analyzed $fileCount ${fileCount == 1 ? 'file' : 'files'}''');

    return issueCount > 0 ? 1 : 0;
  }
}

extension on Severity {
  String? Function(String? value, {bool forScript}) toStyle() {
    switch (this) {
      case Severity.error:
        return lightRed.wrap;
      case Severity.warning:
        return lightYellow.wrap;
      case Severity.info:
        return lightCyan.wrap;
      case Severity.hint:
        return darkGray.wrap;
    }
  }
}

extension on Diagnostic {
  String prettify(String path, TextDocument document) {
    final style = severity.toStyle();
    final text = document.getText(
      range: Range(
        start: Position(line: range.start.line, character: 0),
        end: Position(line: range.start.line, character: 120),
      ),
    );
    final highlight = StringBuffer();
    for (var i = 0; i < range.start.character; i++) {
      highlight.write(' ');
    }
    for (var i = range.start.character; i < range.end.character; i++) {
      highlight.write('^');
    }
    return [
      '''${styleBold.wrap(style('${severity.name}[$code]'))}: ${styleBold.wrap(message)}''',
      ''' ${darkGray.wrap('-->')} ${darkGray.wrap(path)}${darkGray.wrap(':${range.start.line + 1}')}''',
      '''  ${darkGray.wrap('|')}''',
      '''  ${darkGray.wrap('|')} $text''',
      '''  ${darkGray.wrap('|')} ${style(highlight.toString())}''',
      '''  ${darkGray.wrap('=')} ${hint.isNotEmpty ? '${styleBold.wrap('hint:')} $hint' : ''}''',
      ''' ${lightBlue.wrap('docs:')} $description''',
      '',
    ].join('\n');
  }
}
