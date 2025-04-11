import 'dart:convert';
import 'dart:io';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const lintMarker = '^';

@isTest
void lintTest(
  String description, {
  required LintRule Function() rule,
  required String path,
  required String content,
}) {
  test(description, () {
    final lines = const LineSplitter().convert(content);
    final sanitizedLines = StringBuffer();
    final lintedLines = <Range>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;
      final isLint =
          line.contains('^') && line.replaceAll('^', '').trim().isEmpty;

      if (!isLint) {
        sanitizedLines.writeln(line);
        continue;
      }

      sanitizedLines.writeln();
      final lintedLine = lineNumber - 2;
      lintedLines.add(
        Range(
          start: Position(line: lintedLine, character: line.indexOf('^')),
          end: Position(line: lintedLine, character: line.lastIndexOf('^') + 1),
        ),
      );
    }

    const linter = Linter();
    final lintRule = rule();
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(p.join(tempDir.path, path))
      ..writeAsStringSync(content);
    File(p.join(tempDir.path, 'analysis_options.yaml')).writeAsStringSync('''
bloc:
  rules:
    - ${lintRule.name}
''');

    File(p.join(tempDir.path, 'pubspec.lock')).writeAsStringSync('''
packages:
  bloc:
    dependency: "direct main"
    description:
      name: bloc
      sha256: "52c10575f4445c61dd9e0cafcc6356fdd827c4c64dd7945ef3c4105f6b6ac189"
      url: "https://pub.dev"
    source: hosted
    version: "9.0.0"
sdks:
  dart: ">=3.6.0 <4.0.0"
''');

    final diagnostics = linter.analyze(
      uri: tempFile.uri,
      content: sanitizedLines.toString(),
    );

    for (final entry in diagnostics.entries) {
      final diagnostics = entry.value;
      if (diagnostics.isEmpty) expect(lintedLines, isEmpty);
      for (final diagnostic in diagnostics) {
        expect(diagnostic.code, equals(lintRule.name));
        expect(diagnostic.source, equals('bloc'));
        expect(diagnostic.severity, equals(lintRule.severity));
        final reportedRange = json.encode(diagnostic.range.toJson());
        final expectedRanges = lintedLines.map((l) => json.encode(l.toJson()));
        expect(expectedRanges, contains(reportedRange));
      }
    }
  });
}
