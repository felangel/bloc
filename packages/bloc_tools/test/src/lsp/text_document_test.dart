// ignore_for_file: cascade_invocations, require_trailing_commas

import 'package:bloc_tools/src/lsp/text_document.dart';
import 'package:lsp_server/lsp_server.dart' as lsp;
import 'package:test/test.dart';

lsp.Position at({required int line, required int char}) {
  return lsp.Position(character: char, line: line);
}

lsp.Position position(int line, int char) {
  return at(line: line, char: char);
}

lsp.Range range(int startLine, int startChar, int endLine, int endChar) {
  return lsp.Range(
    start: at(line: startLine, char: startChar),
    end: at(line: endLine, char: endChar),
  );
}

TextDocument createDocument(String content) {
  return TextDocument(Uri.parse('test://hello/world'), 'text', 0, content);
}

lsp.Either2<
  lsp.TextDocumentContentChangeEvent1,
  lsp.TextDocumentContentChangeEvent2
>
updateFull(String text) {
  return lsp.Either2.t2(lsp.TextDocumentContentChangeEvent2(text: text));
}

lsp.Either2<
  lsp.TextDocumentContentChangeEvent1,
  lsp.TextDocumentContentChangeEvent2
>
updateIncremental(String text, lsp.Range range) {
  return lsp.Either2.t1(
    lsp.TextDocumentContentChangeEvent1(text: text, range: range),
  );
}

lsp.Range forSubstring(TextDocument document, String substring) {
  final i = document.getText().indexOf(substring);
  final start = document.positionAt(i);
  final end = document.positionAt(i + substring.length);
  final range = lsp.Range(start: start, end: end);
  return range;
}

lsp.Range afterSubstring(TextDocument document, String substring) {
  final i = document.getText().indexOf(substring);
  final pos = document.positionAt(i + substring.length);
  return lsp.Range(start: pos, end: pos);
}

void main() {
  group('lines, offsets and positions', () {
    test('empty content', () {
      final document = createDocument('');

      expect(document.languageId, equals('text'));
      expect(document.lineCount, equals(1));
      expect(document.offsetAt(position(0, 0)), equals(0));

      final pos = document.positionAt(0);
      expect(pos.line, equals(0));
      expect(pos.character, equals(0));
    });

    test('single line', () {
      const content = 'Hello World';
      final document = createDocument(content);
      expect(document.lineCount, equals(1));

      for (var i = 0; i < content.length; i++) {
        expect(document.offsetAt(position(0, i)), equals(i));
        final pos = document.positionAt(i);
        expect(pos.line, equals(0));
        expect(pos.character, equals(i));
      }
    });

    test('multiple lines', () {
      const content = 'abcde\nfghij\nklmno\n';
      final document = createDocument(content);
      expect(document.lineCount, equals(4));

      for (var i = 0; i < content.length; i++) {
        final line = (i / 6).floor();
        final char = i % 6;
        expect(document.offsetAt(position(line, char)), equals(i));

        final pos = document.positionAt(i);
        expect(pos.line, equals(line));
        expect(pos.character, equals(char));
      }

      // Out of bounds.
      expect(document.offsetAt(position(3, 0)), content.length);
      expect(document.offsetAt(position(3, 1)), content.length);

      var pos = document.positionAt(18);
      expect(pos.line, equals(3));
      expect(pos.character, equals(0));

      pos = document.positionAt(19);
      expect(pos.line, equals(3));
      expect(pos.character, equals(0));
    });

    test('starts with newline', () {
      const content = '\nABCDE';
      final document = createDocument(content);
      expect(document.lineCount, equals(2));
    });

    test('newline characters', () {
      var document = createDocument('\rABCDE');
      expect(document.lineCount, equals(2));
      document = createDocument('\nABCDE');
      expect(document.lineCount, equals(2));

      document = createDocument('\r\nABCDE');
      expect(document.lineCount, equals(2));

      document = createDocument('\n\nABCDE');
      expect(document.lineCount, equals(3));

      document = createDocument('\r\rABCDE');
      expect(document.lineCount, equals(3));

      document = createDocument('\n\rABCDE');
      expect(document.lineCount, equals(3));
    });

    test('getText', () {
      const content = 'abcde\nfghij\nklmno';
      final document = createDocument(content);
      expect(document.getText(), equals(content));

      expect(document.getText(range: range(0, 0, 0, 5)), equals('abcde'));
      expect(document.getText(range: range(0, 4, 1, 1)), equals('e\nf'));
    });

    test('invalid input at beginning of file', () {
      final document = createDocument('asdf');
      expect(document.offsetAt(position(-1, 0)), 0);
      expect(document.offsetAt(position(0, -1)), 0);

      final pos = document.positionAt(-1);
      expect(pos.line, equals(0));
      expect(pos.character, equals(0));
    });

    test('invalid input at end of file', () {
      final document = createDocument('asdf');
      expect(document.offsetAt(position(1, 1)), 4);

      final pos = document.positionAt(8);
      expect(pos.line, equals(0));
      expect(pos.character, equals(4));
    });

    test('invalid input at beginning of line', () {
      final document = createDocument('a\ns\nd\r\nf');
      expect(document.offsetAt(position(0, -1)), 0);
      expect(document.offsetAt(position(1, -1)), 2);
      expect(document.offsetAt(position(2, -1)), 4);
      expect(document.offsetAt(position(3, -1)), 7);
    });

    test('invalid input at end of line', () {
      final document = createDocument('a\ns\nd\r\nf');
      expect(document.offsetAt(position(0, 10)), 1);
      expect(document.offsetAt(position(1, 10)), 3);
      expect(document.offsetAt(position(2, 2)), 5);
      expect(document.offsetAt(position(2, 3)), 5);
      expect(document.offsetAt(position(2, 10)), 5);
      expect(document.offsetAt(position(3, 10)), 8);

      final pos = document.positionAt(6);
      expect(pos.line, equals(2));
      expect(pos.character, equals(1));
    });
  });

  group('full updates', () {
    test('one full update', () {
      final document = createDocument('asdfqwer');
      document.update([updateFull('hjklyuio')], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('hjklyuio'));
    });

    test('several full updates', () {
      final document = createDocument('asdfqwer');
      document.update([updateFull('hjklyuio'), updateFull('12345')], 2);
      expect(document.version, equals(2));
      expect(document.getText(), equals('12345'));
    });
  });

  group('incremental updates', () {
    void expectLineAtOffsets(TextDocument document) {
      // Assuming \n.
      final text = document.getText();
      final characters = text.split('');
      var expected = 0;
      for (var i = 0; i < text.length; i++) {
        expect(document.positionAt(i).line, expected);
        if (characters[i] == '\n') {
          expected += 1;
        }
      }
      expect(document.positionAt(text.length).line, equals(expected));
    }

    test('removing content', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('', forSubstring(document, 'abcde')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('removing content over multiple lines', () {
      final document = createDocument('abcde\nfghij\nklmno\npqrst');
      expect(document.version, equals(0));
      expect(document.lineCount, equals(4));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('', forSubstring(document, 'fghij\nklmno')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), 'abcde\n\npqrst');
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('adding content', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('12345', afterSubstring(document, 'abcde\n')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('abcde\n12345fghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('adding content over multiple lines', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental(
          '12345\n67890\n',
          afterSubstring(document, 'abcde\n'),
        ),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('abcde\n12345\n67890\nfghij\nklmno'));
      expect(document.lineCount, equals(5));
      expectLineAtOffsets(document);
    });

    test('replacing single-line content with more content', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('1234567890', forSubstring(document, 'abcde')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('1234567890\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('replacing single-line content with less content', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('1', forSubstring(document, 'abcde')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('1\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('replacing single-line content with same amount of characters', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('12345', forSubstring(document, 'abcde')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('12345\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('replacing multi-line content with more lines', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental(
          '12345\n67890\nABCDE\n',
          forSubstring(document, 'abcde\n'),
        ),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('12345\n67890\nABCDE\nfghij\nklmno'));
      expect(document.lineCount, equals(5));
      expectLineAtOffsets(document);
    });

    test('replacing multi-line content with fewer lines', () {
      final document = createDocument('12345\n67890\nABCDE\nfghij\nklmno');
      expect(document.lineCount, equals(5));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental(
          'abcde\n',
          forSubstring(document, '12345\n67890\nABCDE\n'),
        ),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('abcde\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('replacing multi-line content with same amounts', () {
      final document = createDocument('12345\n67890\nABCDE\nfghij\nklmno');
      expect(document.lineCount, equals(5));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental(
          'abcde\nFGHJI',
          forSubstring(document, 'ABCDE\nfghij'),
        ),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('12345\n67890\nabcde\nFGHJI\nklmno'));
      expect(document.lineCount, equals(5));
      expectLineAtOffsets(document);
    });

    test('replace large number of lines', () {
      final document = createDocument('12345\n67890\nasdf');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      var text = '';
      for (var i = 0; i < 20000; i++) {
        // ignore: use_string_buffers
        text += 'asdf\n';
      }
      document.update([
        updateIncremental(text, forSubstring(document, '67890\n')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), '12345\n${text}asdf');
      expect(document.lineCount, 20002);
      expectLineAtOffsets(document);
    });

    test('several incremental changes', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      expect(document.version, equals(0));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('BCD', forSubstring(document, 'bcd')),
        updateIncremental('LMN', forSubstring(document, 'lmn')),
        updateIncremental('GHI', forSubstring(document, 'ghi')),
      ], 1);
      expect(document.version, equals(1));
      expect(document.getText(), equals('aBCDe\nfGHIj\nkLMNo'));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
    });

    test('append', () {
      final document = createDocument('abcde');
      expect(document.lineCount, equals(1));
      document.update([
        updateIncremental('\nfghij\nklmno', afterSubstring(document, 'abcde')),
      ], 1);
      expect(document.getText(), equals('abcde\nfghij\nklmno'));
      expect(document.lineCount, equals(3));
    });

    test('delete', () {
      final document = createDocument('abcde\nfghij\nklmno');
      expect(document.lineCount, equals(3));
      document.update([updateIncremental('', forSubstring(document, 'o'))], 1);
      expect(document.getText(), equals('abcde\nfghij\nklmn'));
      expect(document.version, equals(1));
      expect(document.lineCount, equals(3));
      expectLineAtOffsets(document);
      document.update([
        updateIncremental('', forSubstring(document, 'fghij\nklmn')),
      ], 2);
      expect(document.getText(), equals('abcde\n'));
      expect(document.version, equals(2));
      expect(document.lineCount, equals(2));
      expectLineAtOffsets(document);
    });

    test('handles weird update ranges', () {
      var document = createDocument('abcde\nfghij');
      document.update([updateIncremental('1234', range(-4, 0, -2, 3))], 1);
      expect(document.getText(), equals('1234abcde\nfghij'));

      document = createDocument('abcde\nfghij');
      document.update([updateIncremental('1234', range(-1, 0, 0, 5))], 1);
      expect(document.getText(), equals('1234\nfghij'));

      document = createDocument('abcde\nfghij');
      document.update([updateIncremental('1234', range(1, 0, 13, 14))], 1);
      expect(document.getText(), equals('abcde\n1234'));

      document = createDocument('abcde\nfghij');
      document.update([updateIncremental('1234', range(13, 0, 35, 14))], 1);
      expect(document.getText(), equals('abcde\nfghij1234'));

      document = createDocument('abcde\nfghij');
      document.update([updateIncremental('1234', range(-13, 0, 35, 14))], 1);
      expect(document.getText(), equals('1234'));
    });
  });

  group('getWellFormedRange', () {
    test('swaps start and end when needed', () {
      final document = createDocument('hello');
      final range = lsp.Range(
        start: lsp.Position(character: 2, line: 1),
        end: lsp.Position(character: 1, line: 1),
      );
      final wellformedRange = document.getWellformedRange(range);
      expect(wellformedRange.start, equals(range.end));
      expect(wellformedRange.end, equals(range.start));
    });
  });
}
