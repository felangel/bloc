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
  AvoidFlutterImports(),
  AvoidMutableFields(),
  AvoidPublicBlocMethods(),
  PreferBlocLint(),
  PreferCubitLint(),
];

/// All recommended lint rules.
const recommendedRules = <LintRule>[
  AvoidFlutterImports(),
  AvoidMutableFields(),
  AvoidPublicBlocMethods(),
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
    if (directory.existsSync()) return _analyzeDirectory(directory);
    final file = File(uri.path);
    if (file.existsSync()) return _analyzeFile(file);
    return {};
  }

  Map<String, List<Diagnostic>> _analyzeDirectory(Directory directory) {
    final files =
        directory
            .listSync(recursive: true)
            .where((e) => e.isLintableDartFile)
            .cast<File>();

    return files
        .map(_analyzeFile)
        .fold(<String, List<Diagnostic>>{}, (prev, cur) => {...prev, ...cur});
  }

  Map<String, List<Diagnostic>> _analyzeFile(File file) {
    return _analyzeContent(file.uri, file.readAsStringSync());
  }

  Map<String, List<Diagnostic>> _analyzeContent(Uri uri, String content) {
    final diagnostics = <Diagnostic>[];
    final document = TextDocument(uri: uri, content: content);
    final tokens = scan(utf8.encode(content)).tokens;
    for (final rule in rules) {
      final context = LintContext._(rule: rule, document: document);
      final listener = rule.create(context);
      if (listener == null) continue;
      Parser(listener).parseUnit(tokens);
      diagnostics.addAll(context.diagnostics);
    }
    return {uri.path: diagnostics};
  }
}

extension on FileSystemEntity {
  bool get isLintableDartFile {
    return this is File &&
        p.extension(path) == '.dart' &&
        !p.basename(path).endsWith('.g.dart') &&
        !p.split(path).contains('.dart_tool');
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

  /// Reports a lint at the provided [range].
  void report({
    required Range range,
    required String message,
    String hint = '',
  }) {
    _diagnostics.add(
      Diagnostic(
        range: range,
        source: 'bloc',
        message: message,
        hint: hint,
        code: _rule.name,
        description: 'https://bloclibrary.dev/lint-rules/${_rule.name}',
        severity: _rule.severity,
      ),
    );
  }

  /// Reports a lint from [beginToken] to [endToken].
  void reportTokenRange({
    required Token beginToken,
    required Token endToken,
    required String message,
    String hint = '',
  }) {
    report(
      range: Range(
        start: document.positionAt(beginToken.offset),
        end: document.positionAt(endToken.offset),
      ),
      message: message,
      hint: hint,
    );
  }

  /// Reports a lint at the specified [token].
  void reportToken({
    required Token token,
    required String message,
    String hint = '',
  }) {
    report(
      range: Range(
        start: document.positionAt(token.offset),
        end: document.positionAt(token.offset + token.length),
      ),
      message: message,
      hint: hint,
    );
  }
}
