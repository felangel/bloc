import 'dart:convert';
import 'dart:io';

import 'package:bloc_lint/src/diagnostic.dart';
import 'package:checked_yaml/checked_yaml.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

part 'analysis_options.g.dart';

/// {@template analysis_options}
/// The analysis_options object which contains the parsed
/// yaml as well as the file path.
/// {@endtemplate}
class AnalysisOptions {
  /// {@macro analysis_options}
  const AnalysisOptions({required this.file, required this.yaml});

  /// Parse the [file] as an [AnalysisOptions].
  factory AnalysisOptions.parse(File file) {
    final content = file.readAsStringSync();
    final yaml = checkedYamlDecode(
      content,
      (m) => AnalysisOptionsYaml.fromJson(m!),
    );
    return AnalysisOptions(file: file, yaml: yaml);
  }

  /// Resolve the provided options by recursively joining all includes.
  factory AnalysisOptions.resolve(File file) {
    AnalysisOptions recursiveResolver(
      File file,
      Directory root,
      Map<String, dynamic> yaml,
    ) {
      final options = AnalysisOptions.parse(file);
      for (final include in options.yaml.include ?? <String>[]) {
        final isPackageInclude = include.startsWith('package:');
        final parsedOptions =
            isPackageInclude
                ? AnalysisOptions.tryInclude(include, cwd: root)
                : AnalysisOptions.tryParse(
                  File(p.normalize(p.join(options.file.parent.path, include))),
                );
        if (parsedOptions == null) continue;
        final resolved = recursiveResolver(
          parsedOptions.file,
          isPackageInclude ? root : file.parent,
          yaml,
        );
        // Accumulate the merged analysis_options yaml content
        // ignore: parameter_assignments
        yaml = _merge(yaml, resolved.yaml.toJson());
      }

      return AnalysisOptions(
        file: options.file,
        yaml: AnalysisOptionsYaml.fromJson(_merge(yaml, options.yaml.toJson())),
      );
    }

    return recursiveResolver(file, file.parent, {});
  }

  /// Try to parse [file] and return `null` if parsing fails.
  static AnalysisOptions? tryParse(File file) {
    try {
      final options = AnalysisOptions.parse(file);
      return options;
    } on Exception {
      return null;
    }
  }

  /// Try to resolve [file] and return `null` if resolving fails.
  static AnalysisOptions? tryResolve(File file) {
    try {
      return AnalysisOptions.resolve(file);
    } on Exception {
      return null;
    }
  }

  /// Try to parse an analysis_options yaml referenced by the [include].
  static AnalysisOptions? tryInclude(String include, {required Directory cwd}) {
    final packagePrefix = include.split(p.separator).first;
    final packageName = packagePrefix.split('package:').last;
    final packageConfigFile = File(
      p.join(cwd.path, '.dart_tool', 'package_config.json'),
    );
    if (!packageConfigFile.existsSync()) return null;
    final packageConfig =
        json.decode(packageConfigFile.readAsStringSync())
            as Map<String, dynamic>;
    final packages = packageConfig['packages'] as List;
    final package = packages.cast<Map<String, dynamic>>().firstWhereOrNull(
      (entry) => entry['name'] == packageName,
    );
    if (package == null) return null;
    final fullUri = Uri.tryParse(
      p.join(package['rootUri'] as String, package['packageUri'] as String),
    );
    if (fullUri == null) return null;
    var path = include.split(packagePrefix).last;
    if (path.startsWith(p.separator)) path = path.substring(1);
    var resolvedPath = fullUri.path + path;
    if (!p.isAbsolute(resolvedPath)) {
      resolvedPath = p.join(packageConfigFile.parent.path, resolvedPath);
    }
    return AnalysisOptions.tryParse(File(p.normalize(resolvedPath)));
  }

  /// The `analysis_options.yaml` file.
  final File file;

  /// The parsed yaml contents.
  final AnalysisOptionsYaml yaml;
}

/// {@template analysis_options_yaml}
/// The `analysis_options.yaml` configuration.
/// {@endtemplate}
@JsonSerializable()
class AnalysisOptionsYaml {
  /// {@macro analysis_options_yaml}
  AnalysisOptionsYaml({this.include, this.analyzer, this.bloc});

  /// Converts [Map] to [AnalysisOptionsYaml]
  factory AnalysisOptionsYaml.fromJson(Map<dynamic, dynamic> json) =>
      _$AnalysisOptionsYamlFromJson(json);

  /// Converts [AnalysisOptionsYaml] to [Map].
  Map<String, dynamic> toJson() => _$AnalysisOptionsYamlToJson(this);

  /// The list of shared analysis options.
  @IncludeConverter()
  final List<String>? include;

  /// The dart analyzer options.
  final AnalyzerOptions? analyzer;

  /// The bloc lint options.
  final BlocLintOptions? bloc;
}

/// {@template analyzer_options}
/// Dart analyzer options.
/// {@endtemplate}
@JsonSerializable()
class AnalyzerOptions {
  /// {@macro analyzer_options}
  const AnalyzerOptions({this.exclude = const <String>[]});

  /// Converts [Map] to [AnalyzerOptions]
  factory AnalyzerOptions.fromJson(Map<dynamic, dynamic> json) =>
      _$AnalyzerOptionsFromJson(json);

  /// Converts [AnalyzerOptions] to [Map].
  Map<String, dynamic> toJson() => _$AnalyzerOptionsToJson(this);

  /// List of files, directories, or globs to exclude.
  final List<String> exclude;
}

/// {@template bloc_lint_options}
/// Bloc-specific lint options.
/// {@endtemplate}
@JsonSerializable()
class BlocLintOptions {
  /// {@macro bloc_lint_options}
  const BlocLintOptions({required this.rules});

  /// Converts [Map] to [BlocLintOptions].
  factory BlocLintOptions.fromJson(Map<dynamic, dynamic> json) =>
      _$BlocLintOptionsFromJson(json);

  /// Converts [BlocLintOptions] to [Map].
  Map<String, dynamic> toJson() => _$BlocLintOptionsToJson(this);

  /// The configured bloc lint rules.
  @RulesConverter()
  final Map<String, LinterRuleState>? rules;
}

@JsonEnum(valueField: 'value')
/// The state of a given linter rule.
enum LinterRuleState {
  /// The rule is enabled with a default severity.
  enabled('true'),

  /// The rule is disabled.
  disabled('false'),

  /// The rule is enabled with a severity of info.
  info('info'),

  /// The rule is enabled with a severity of error.
  error('error'),

  /// The rule is enabled with a severity of warning.
  warning('warning'),

  /// The rule is enabled with a severity of hint.
  hint('hint');

  const LinterRuleState(this.value);

  /// The underlying value.
  final String value;

  /// Parse the provided [value] as a [LinterRuleState].
  static LinterRuleState fromJson(String value) {
    return LinterRuleState.values.firstWhere((v) => v.value == value);
  }

  /// Converts the [LinterRuleState] to a json encoded value.
  String toJson() => value;
}

/// {@template include_converter}
/// Json Converter for analysis_options includes (`List<String>`).
/// {@endtemplate}
class IncludeConverter implements JsonConverter<List<String>?, dynamic> {
  /// {@macro include_converter}
  const IncludeConverter();

  @override
  dynamic toJson(List<String>? value) => value;

  @override
  List<String>? fromJson(dynamic value) {
    if (value is String) return [value];
    if (value is List) return value.cast<String>();
    return null;
  }
}

/// {@template rules_converter}
/// Json Converter for lint rules (`Map<String, LinterRuleState>`).
/// {@endtemplate}
class RulesConverter
    implements JsonConverter<Map<String, LinterRuleState>?, dynamic> {
  /// {@macro rules_converter}
  const RulesConverter();

  @override
  dynamic toJson(Map<String, LinterRuleState>? value) {
    return value?.map<String, String>(
      (key, value) => MapEntry(key, value.toJson()),
    );
  }

  @override
  Map<String, LinterRuleState>? fromJson(dynamic value) {
    final dynamic decoded = value is String ? json.decode(value) : value;
    if (decoded is List) {
      return <String, LinterRuleState>{
        for (final v in decoded) v as String: LinterRuleState.enabled,
      };
    }
    if (decoded is Map) {
      return decoded.map(
        (dynamic key, dynamic value) => MapEntry(
          key as String,
          LinterRuleState.fromJson(decoded[key].toString()),
        ),
      );
    }
    return null;
  }
}

/// Extension methods on [LinterRuleState].
extension LinterRuleStateX on LinterRuleState {
  /// Whether the rule is enabled.
  bool get isEnabled => this != LinterRuleState.disabled;

  /// Whether the rule is disabled.
  bool get isDisabled => !isEnabled;

  /// Converts the rule to a [Severity] using the [fallback].
  Severity? toSeverity({Severity? fallback}) {
    return switch (this) {
      LinterRuleState.enabled => fallback,
      LinterRuleState.disabled => null,
      LinterRuleState.info => Severity.info,
      LinterRuleState.error => Severity.error,
      LinterRuleState.warning => Severity.warning,
      LinterRuleState.hint => Severity.hint,
    };
  }
}

/// Merge two maps recursively.
Map<String, dynamic> _merge(
  Map<String, dynamic> mapA,
  Map<String, dynamic> mapB,
) {
  return mergeMaps(
    mapA,
    mapB,
    value: (p0, p1) {
      if (p0 is Map<String, dynamic> && p1 is Map<String, dynamic>) {
        return _merge(p0, p1);
      } else if (p0 is List && p1 is List) {
        return {...p0, ...p1}.toList();
      } else {
        return p1;
      }
    },
  );
}
