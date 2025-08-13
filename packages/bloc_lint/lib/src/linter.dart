import 'dart:convert';
import 'dart:io';

// Use the parser from the shared frontend.
// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/parser/parser.dart' show Parser;
// Use the scanner from the shared frontend.
// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart' show scan;
import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_lint/src/analysis_options.dart';
import 'package:bloc_lint/src/env.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// All supported lint rules.
final allRules = <String, LintRuleBuilder>{
  AvoidBuildContextExtensions.rule: AvoidBuildContextExtensions.new,
  AvoidFlutterImports.rule: AvoidFlutterImports.new,
  AvoidPublicBlocMethods.rule: AvoidPublicBlocMethods.new,
  AvoidPublicFields.rule: AvoidPublicFields.new,
  PreferBloc.rule: PreferBloc.new,
  PreferCubit.rule: PreferCubit.new,
  PreferFileNamingConventions.rule: PreferFileNamingConventions.new,
  PreferVoidPublicCubitMethods.rule: PreferVoidPublicCubitMethods.new,
  PreferBuildContextExtensions.rule: PreferBuildContextExtensions.new,
};

/// {@template linter}
/// A class that is able to analyze files and directories and
/// report diagnostics based on a registered set of lint rules.
/// {@endtemplate}
class Linter {
  /// {@macro linter}
  const Linter();

  /// Analyzes the provided [uri] and returns all reported diagnostics. If
  /// [content] is provided, it will be explicitly analyzed, otherwise the [uri]
  /// will be analyzed (both single files and directories are supported).
  Map<String, List<Diagnostic>> analyze({required Uri uri, String? content}) {
    final path = uri.canonicalizedPath.toLongPath();
    final directory = Directory(path);
    if (directory.existsSync()) return _analyzeDirectory(directory);
    final file = File(path);
    if (file.existsSync() && file.isLintableDartFile) {
      if (content != null) return _analyzeContent(uri, content);
      return _analyzeFile(file);
    }
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
    final canonicalizedPath = uri.canonicalizedPath;
    final results = {canonicalizedPath: diagnostics};
    final path = canonicalizedPath.toLongPath();
    final cwd = File(path).parent;
    final pubspecLock = findPubspecLock(cwd);
    if (pubspecLock == null) return results;
    if (!pubspecLock.packages.keys.contains('bloc')) return results;
    final analysisOptions = findAnalysisOptions(cwd);
    if (analysisOptions == null) return results;
    final relativePath = p
        .relative(path, from: analysisOptions.file.parent.path)
        .replaceAll(r'\', '/');
    if (analysisOptions.excludes.any((e) => e.matches(relativePath))) {
      return results;
    }
    final document = TextDocument(uri: uri, content: content);
    final ignoreForFile = document.ignoreForFile;
    if (ignoreForFile.containsTypeLint) return results;
    final enabledRules = {...analysisOptions.lintRules}
      ..removeWhere((rule) => ignoreForFile.contains(rule.name));
    final tokens = scan(utf8.encode(content)).tokens;
    for (final rule in enabledRules) {
      final context = LintContext._(rule: rule, document: document);
      final listener = rule.create(context);
      if (listener == null) continue;
      Parser(listener).parseUnit(tokens);
      diagnostics.addAll(context.diagnostics);
    }
    return results;
  }
}

extension on AnalysisOptions {
  /// Gets the list of [Glob] patterns to be excluded for this project.
  List<Glob> get excludes {
    final excludes = yaml.analyzer?.exclude ?? <String>[];
    final context = p.Context(current: file.parent.path);
    return excludes.map((e) => Glob(e, context: context)).toList();
  }

  /// Gets the list of [LintRule] for this project.
  List<LintRule> get lintRules {
    final blocLintOptions = yaml.bloc;
    if (blocLintOptions == null) return [];
    final rules = blocLintOptions.rules;
    if (rules == null) return [];
    return rules.entries
        .map<LintRule?>((analysisEntry) {
          final rule = analysisEntry.key;
          final state = analysisEntry.value;
          if (state.isDisabled) return null;
          final entry = allRules.entries.firstWhereOrNull((e) => e.key == rule);
          if (entry == null) return null;
          final builder = entry.value;
          final severity = state.toSeverity(fallback: builder().severity);
          return builder(severity);
        })
        .whereType<LintRule>()
        .toList();
  }
}

extension on FileSystemEntity {
  bool get isLintableDartFile {
    return this is File &&
        p.extension(path) == '.dart' &&
        !p.basename(path).endsWith('.g.dart') &&
        !p.split(path).any((segment) => segment.startsWith('.'));
  }
}

extension on String {
  String toLongPath() {
    // Support long file paths on Windows
    // https://github.com/dart-lang/sdk/issues/27825
    if (Platform.isWindows) return r'\\?\' + this;
    return this;
  }
}

extension on Uri {
  String get canonicalizedPath {
    final path = isScheme('file') ? p.fromUri(this) : this.path;
    return p.normalize(p.absolute(path));
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
    final ignore = document.ignoreForLine(range: range);
    if (ignore.containsTypeLint || ignore.contains(_rule.name)) return;
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
        end: document.positionAt(endToken.offset + endToken.length),
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

extension on Set<String> {
  /// Whether the set of strings contains `type=lint`.
  bool get containsTypeLint => contains('type=lint');
}
