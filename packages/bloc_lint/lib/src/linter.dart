import 'dart:convert';
import 'dart:io';

// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/parser/parser.dart' show Parser;
// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart' show scan;
import 'package:bloc_lint/bloc_lint.dart';
import 'package:path/path.dart' as p;

/// All supported lint rules.
const allRules = <LintRule>[
  AvoidDependingOnFlutter(),
  AvoidPublicBlocMethods(),
  PreferBlocLint(),
  PreferCubitLint(),
];

/// {@template linter}
/// A class that is able to analyze files and directories and
/// report diagnostics based on a registered set of lint rules.
/// {@endtemplate}
class Linter {
  /// {@macro linter}
  const Linter({required this.rules});

  /// The lint rules
  final List<LintRule> rules;

  /// Analyzes the provided [uri] and returns all reported diagnostics. If
  /// [content] is provided, it will be explicitly analyzed, otherwise the [uri]
  /// will be analyzed (both single files and directories are supported).
  Map<String, List<Diagnostic>> analyze({required Uri uri, String? content}) {
    if (content != null) return _analyzeContent(uri, content);
    final directory = Directory(uri.path);
    final file = File(uri.path);
    if (directory.existsSync()) return _analyzeDirectory(directory);
    if (file.existsSync()) return _analyzeFile(file);
    return {};
  }

  Map<String, List<Diagnostic>> _analyzeDirectory(Directory directory) {
    final files =
        directory
            .listSync(recursive: true)
            .where(
              (e) =>
                  e is File &&
                  p.extension(e.path) == '.dart' &&
                  !p.basename(e.path).endsWith('.g.dart') &&
                  !p.split(e.path).contains('.dart_tool'),
            )
            .cast<File>();

    return files
        .map(_analyzeFile)
        .fold(<String, List<Diagnostic>>{}, (prev, cur) => {...prev, ...cur});
  }

  Map<String, List<Diagnostic>> _analyzeFile(File file) {
    final diagnostics = <Diagnostic>[];
    final content = file.readAsStringSync();
    final document = TextDocument(uri: file.uri, content: content);
    final tokens = scan(utf8.encode(content)).tokens;
    for (final rule in rules) {
      final context = LintContext._(rule: rule, document: document);
      Parser(rule.create(context)).parseUnit(tokens);
      diagnostics.addAll(context.diagnostics);
    }
    return {file.path: diagnostics};
  }

  Map<String, List<Diagnostic>> _analyzeContent(Uri uri, String content) {
    final diagnostics = <Diagnostic>[];
    final document = TextDocument(uri: uri, content: content);
    final tokens = scan(utf8.encode(content)).tokens;
    for (final rule in rules) {
      final context = LintContext._(rule: rule, document: document);
      Parser(rule.create(context)).parseUnit(tokens);
      diagnostics.addAll(context.diagnostics);
    }
    return {uri.path: diagnostics};
  }
}

/// {@template lint_context}
/// A context object that is provided to each [LintRule] and
/// provides APIs for reporting diagnostics and accessing the
/// current [TextDocument].
/// {@endtemplate}
class LintContext {
  /// {@macro lint_context}
  LintContext._({required LintRule rule, required this.document})
    : _rule = rule;

  final LintRule _rule;

  /// The current [document] being analyzed.
  final TextDocument document;

  final List<Diagnostic> _diagnostics = [];

  /// The list of reported diagnostics.
  List<Diagnostic> get diagnostics => _diagnostics;

  /// Reports a lint at the provided [token].
  void report({
    required Token token,
    required String message,
    String hint = '',
  }) {
    _diagnostics.add(
      Diagnostic(
        range: Range(
          start: document.positionAt(token.offset),
          end: document.positionAt(token.offset + token.length),
        ),
        source: 'bloc',
        message: message,
        hint: hint,
        code: _rule.name,
        description: 'https://bloclibrary.dev/lint-rules/${_rule.name}',
        severity: _rule.severity,
      ),
    );
  }
}
