import 'dart:convert';
import 'dart:io';

import 'package:bloc_lint/src/analysis_options.dart';
import 'package:bloc_lint/src/diagnostic.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group(AnalysisOptionsYaml, () {
    test('(de)serializes correctly', () {
      final options = AnalysisOptionsYaml(
        include: ['include.yaml'],
        analyzer: const AnalyzerOptions(exclude: ['exclude']),
        bloc: const BlocLintOptions(
          rules: {'prefer_bloc': LinterRuleState.enabled},
        ),
      );
      expect(
        json.encode(AnalysisOptionsYaml.fromJson(options.toJson()).toJson()),
        equals(json.encode(options.toJson())),
      );
    });
  });

  group(AnalysisOptions, () {
    group('tryParse', () {
      test('returns null for invalid file', () {
        expect(AnalysisOptions.tryParse(File('invalid')), isNull);
      });
    });

    group('parse', () {
      test('completes for empty file', () {
        final tempDir = Directory.systemTemp.createTempSync();
        final file = File(p.join(tempDir.path, 'analysis_options.yaml'))
          ..writeAsStringSync('{}');
        final parsed = AnalysisOptions.parse(file);
        expect(parsed.file.path, equals(file.path));
        expect(parsed.yaml.analyzer, isNull);
        expect(parsed.yaml.include, isNull);
        expect(parsed.yaml.bloc, isNull);
      });

      test('completes for valid file', () {
        final tempDir = Directory.systemTemp.createTempSync();
        final file = File(p.join(tempDir.path, 'analysis_options.yaml'))
          ..writeAsStringSync('''
include: package:bloc_lint/recommended.yaml

analyzer:
  exclude:
    - "**.g.dart"

linter:
  rules:
    public_member_api_docs: false

bloc:
  rules:
    prefer_bloc: true
''');
        final parsed = AnalysisOptions.parse(file);
        expect(parsed.file.path, equals(file.path));
        expect(parsed.yaml.analyzer?.exclude, equals(['**.g.dart']));
        expect(
          parsed.yaml.include,
          equals(['package:bloc_lint/recommended.yaml']),
        );
        expect(
          parsed.yaml.bloc?.rules,
          equals({'prefer_bloc': LinterRuleState.enabled}),
        );
      });
    });

    group('tryResolve', () {
      test('returns null for invalid file', () {
        expect(AnalysisOptions.tryResolve(File('invalid')), isNull);
      });
    });

    group('resolve', () {
      test('resolves with no includes', () {
        final tempDir = Directory.systemTemp.createTempSync();
        final file = File(p.join(tempDir.path, 'analysis_options.yaml'))
          ..writeAsStringSync('''
analyzer:
  exclude:
    - "**.g.dart"

linter:
  rules:
    public_member_api_docs: false

bloc:
  rules:
    prefer_bloc: true
''');
        final parsed = AnalysisOptions.resolve(file);
        expect(parsed.file.path, equals(file.path));
        expect(parsed.yaml.analyzer?.exclude, equals(['**.g.dart']));
        expect(parsed.yaml.include, isNull);
        expect(
          parsed.yaml.bloc?.rules,
          equals({'prefer_bloc': LinterRuleState.enabled}),
        );
      });

      test('resolves with package include', () {
        final tempDir = Directory.systemTemp.createTempSync();
        File(p.join(tempDir.path, 'bloc_lint', 'lib', 'recommended.yaml'))
          ..createSync(recursive: true)
          ..writeAsStringSync('''
bloc:
  rules:
    - avoid_flutter_imports
    - avoid_public_bloc_methods
    - avoid_public_fields
''');
        File(p.join(tempDir.path, '.dart_tool', 'package_config.json'))
          ..createSync(recursive: true)
          ..writeAsStringSync('''
{
  "packages": [
    {
      "name": "bloc_lint",
      "rootUri": "../bloc_lint",
      "packageUri": "lib/",
      "languageVersion": "3.7"
    }
  ]
}
''');
        final file = File(p.join(tempDir.path, 'analysis_options.yaml'))
          ..writeAsStringSync('''
include: package:bloc_lint/recommended.yaml
analyzer:
  exclude:
    - "**.g.dart"

bloc:
  rules:
    prefer_bloc: true
''');
        final parsed = AnalysisOptions.resolve(file);
        expect(parsed.file.path, equals(file.path));
        expect(parsed.yaml.analyzer?.exclude, equals(['**.g.dart']));
        expect(parsed.yaml.include, ['package:bloc_lint/recommended.yaml']);
        expect(
          parsed.yaml.bloc?.rules,
          equals({
            'avoid_flutter_imports': LinterRuleState.enabled,
            'avoid_public_bloc_methods': LinterRuleState.enabled,
            'avoid_public_fields': LinterRuleState.enabled,
            'prefer_bloc': LinterRuleState.enabled,
          }),
        );
      });

      test('resolves with nested includes', () {
        final tempDir = Directory.systemTemp.createTempSync();
        File(p.join(tempDir.path, 'one.yaml')).writeAsStringSync('''
analyzer:
  exclude:
    - one.dart

bloc:
  rules:
    avoid_flutter_imports: error
''');
        File(p.join(tempDir.path, 'two.yaml')).writeAsStringSync('''
analyzer:
  exclude:
    - two.dart

bloc:
  rules:
    prefer_bloc: error
    prefer_cubit: warning
''');

        File(p.join(tempDir.path, 'three.yaml')).writeAsStringSync('''
include: two.yaml

analyzer:
  exclude:
    - three.dart

bloc:
  rules:
    prefer_bloc: false
''');
        final options = File(p.join(tempDir.path, 'analysis_options.yaml'))
          ..writeAsStringSync('''
include:
  - one.yaml
  - three.yaml

analyzer:
  exclude:
    - "**.g.dart"

bloc:
  rules:
    avoid_public_fields: true
''');
        final parsed = AnalysisOptions.resolve(options);
        expect(parsed.file.path, equals(options.path));
        expect(
          parsed.yaml.analyzer?.exclude,
          equals(['one.dart', 'two.dart', 'three.dart', '**.g.dart']),
        );
        expect(
          parsed.yaml.include,
          equals(['two.yaml', 'one.yaml', 'three.yaml']),
        );
        expect(
          parsed.yaml.bloc?.rules,
          equals({
            'avoid_flutter_imports': LinterRuleState.error,
            'prefer_cubit': LinterRuleState.warning,
            'prefer_bloc': LinterRuleState.disabled,
            'avoid_public_fields': LinterRuleState.enabled,
          }),
        );
      });
    });
  });

  group(LinterRuleState, () {
    test('toSeverity is correct', () {
      expect(
        LinterRuleState.enabled.toSeverity(fallback: Severity.info),
        equals(Severity.info),
      );
      expect(LinterRuleState.disabled.toSeverity(), equals(null));
      expect(LinterRuleState.info.toSeverity(), equals(Severity.info));
      expect(LinterRuleState.error.toSeverity(), equals(Severity.error));
      expect(LinterRuleState.warning.toSeverity(), equals(Severity.warning));
      expect(LinterRuleState.hint.toSeverity(), equals(Severity.hint));
    });
  });
}
