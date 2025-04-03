import 'dart:convert';

import 'package:bloc_lint/bloc_lint.dart';
import 'package:test/test.dart';

void main() {
  group(Diagnostic, () {
    group('toJson', () {
      test('returns correct value', () {
        expect(
          json.encode(
            const Diagnostic(
              range: Range(
                start: Position(line: 1, character: 2),
                end: Position(line: 3, character: 4),
              ),
              source: 'source',
              message: 'message',
              description: 'description',
              hint: 'hint',
              code: 'code',
              severity: Severity.error,
            ).toJson(),
          ),
          equals(
            json.encode({
              'range': {
                'start': {'line': 1, 'character': 2},
                'end': {'line': 3, 'character': 4},
              },
              'source': 'source',
              'message': 'message',
              'description': 'description',
              'hint': 'hint',
              'code': 'code',
              'severity': 'error',
            }),
          ),
        );
      });
    });
  });
}
