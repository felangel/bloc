import 'dart:convert';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:meta/meta.dart';
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

    final lintRule = rule();
    final linter = Linter(rules: [lintRule]);
    final diagnostics = linter.analyze(
      uri: Uri.parse(path),
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
