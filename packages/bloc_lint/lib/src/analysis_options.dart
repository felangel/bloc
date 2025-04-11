import 'dart:convert';
import 'dart:io';

import 'package:bloc_lint/src/diagnostic.dart';
import 'package:checked_yaml/checked_yaml.dart';
import 'package:json_annotation/json_annotation.dart';

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

  /// Try to parse [file] and return `null` if parsing fails.
  static AnalysisOptions? tryParse(File file) {
    try {
      return AnalysisOptions.parse(file);
    } on Exception {
      return null;
    }
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
  AnalysisOptionsYaml({this.analyzer, this.bloc});

  /// Converts [Map] to [AnalysisOptionsYaml]
  factory AnalysisOptionsYaml.fromJson(Map<dynamic, dynamic> json) =>
      _$AnalysisOptionsYamlFromJson(json);

  /// Converts [AnalysisOptionsYaml] to [Map].
  Map<String, dynamic> toJson() => _$AnalysisOptionsYamlToJson(this);

  /// The dart analyzer options.
  final AnalyzerOptions? analyzer;

  /// The bloc analysis options.
  final BlocAnalysisOptions? bloc;
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

/// {@template bloc_linter}
/// Bloc-specific lint rules.
/// {@endtemplate}
@JsonSerializable()
class BlocAnalysisOptions {
  /// {@macro bloc_linter}
  const BlocAnalysisOptions({required this.rules});

  /// Converts [Map] to [BlocAnalysisOptions].
  factory BlocAnalysisOptions.fromJson(Map<dynamic, dynamic> json) =>
      _$BlocAnalysisOptionsFromJson(json);

  /// Converts [BlocAnalysisOptions] to [Map].
  Map<String, dynamic> toJson() => _$BlocAnalysisOptionsToJson(this);

  /// The configured bloc lint rules.
  @RulesConverter()
  final Map<String, LinterRuleState> rules;
}

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
  static LinterRuleState parse(String value) {
    return LinterRuleState.values.firstWhere((v) => v.value == value);
  }

  /// Converts the [LinterRuleState] to a [Map].
  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

/// {@template rules_converter}
/// Json Converter for [Map<String, LinterRuleState>].
/// {@endtemplate}
class RulesConverter
    implements JsonConverter<Map<String, LinterRuleState>, dynamic> {
  /// {@macro rules_converter}
  const RulesConverter();

  @override
  dynamic toJson(Map<String, LinterRuleState> value) {
    return value.map((key, value) => MapEntry(key, value.toJson()));
  }

  @override
  Map<String, LinterRuleState> fromJson(dynamic value) {
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
          LinterRuleState.parse(decoded[key].toString()),
        ),
      );
    }
    throw const FormatException();
  }
}

/// Extension methods on [LinterRuleState].
extension LinterRuleStateX on LinterRuleState {
  /// Whether the rule is enabled.
  bool get isEnabled => this != LinterRuleState.disabled;

  /// Whether the rule is disabled.
  bool get isDisabled => !isEnabled;

  /// Converts the rule to a [Severity] using the [fallback].
  Severity? toSeverity({required Severity fallback}) {
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
