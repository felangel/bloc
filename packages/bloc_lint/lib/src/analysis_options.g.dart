// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter, require_trailing_commas, cast_nullable_to_non_nullable, lines_longer_than_80_chars, strict_raw_type

part of 'analysis_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisOptionsYaml _$AnalysisOptionsYamlFromJson(Map json) =>
    $checkedCreate('AnalysisOptionsYaml', json, ($checkedConvert) {
      final val = AnalysisOptionsYaml(
        analyzer: $checkedConvert(
          'analyzer',
          (v) => v == null ? null : AnalyzerOptions.fromJson(v as Map),
        ),
        bloc: $checkedConvert(
          'bloc',
          (v) => v == null ? null : BlocAnalysisOptions.fromJson(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnalysisOptionsYamlToJson(
  AnalysisOptionsYaml instance,
) => <String, dynamic>{
  if (instance.analyzer?.toJson() case final value?) 'analyzer': value,
  if (instance.bloc?.toJson() case final value?) 'bloc': value,
};

AnalyzerOptions _$AnalyzerOptionsFromJson(Map json) =>
    $checkedCreate('AnalyzerOptions', json, ($checkedConvert) {
      final val = AnalyzerOptions(
        exclude: $checkedConvert(
          'exclude',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$AnalyzerOptionsToJson(AnalyzerOptions instance) =>
    <String, dynamic>{'exclude': instance.exclude};

BlocAnalysisOptions _$BlocAnalysisOptionsFromJson(Map json) =>
    $checkedCreate('BlocAnalysisOptions', json, ($checkedConvert) {
      final val = BlocAnalysisOptions(
        rules: $checkedConvert(
          'rules',
          (v) => const RulesConverter().fromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BlocAnalysisOptionsToJson(
  BlocAnalysisOptions instance,
) => <String, dynamic>{
  if (const RulesConverter().toJson(instance.rules) case final value?)
    'rules': value,
};
